provider "aws" {
  region = "us-east-1"
}



terraform {
  backend "s3" {
    bucket = "terraform-playsdev"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  env                 = "terraform"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

}


module "SG_SSH" {
  source        = "./modules/SG"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraform-ssh-access-sg"
  sg_description = "Security group for SSH access"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowed_ip]
      description = "Allow SSH from specific IP"
    }
  ]
}

module "bastion_host" {
  source             = "./modules/ec2/bastion"
  instance_name      = "bastion-host"
  ami                = "ami-0e86e20dae9224db8"
  instance_type      = "t2.micro"
  key_name           = "Task8"
  subnet_id          = element(module.vpc.public_subnet_ids, 0)
  security_group_ids = [module.SG_SSH.security_group_id]
  
  enable_file_provisioner = true
  file_source             = "/home/eugene/Downloads/PrivateServer.pem"
  file_destination        = "/tmp/PrivateServer.pem"
  private_key             = "/home/eugene/Downloads/Task8.pem"

  remote_exec_commands = [
    "mkdir -p /home/ubuntu/uploads",
    "mv /tmp/PrivateServer.pem /home/ubuntu/uploads/PrivateServer.pem",
    "chmod 400 /home/ubuntu/uploads/PrivateServer.pem",
    "echo 'File uploaded and permissions set to 400!' > /home/ubuntu/uploads/upload_success.txt"
  ]
}

module "private_server" {
  source             = "./modules/ec2/privateServer"
  instance_name      = "private-server"
  ami                = "ami-0e86e20dae9224db8"
  instance_type      = "t2.micro"
  key_name           = "PrivateServer"
  subnet_id          = element(module.vpc.private_subnet_ids, 0)
  security_group_ids = [module.SG_SSH.security_group_id]
  user_data = <<-EOF
            #!/bin/bash
            sudo apt install -y postgresql-common
            sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
            sudo apt install curl ca-certificates
            sudo install -d /usr/share/postgresql-common/pgdg
            sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
            sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
            sudo apt update
            sudo apt -y install postgresql

              EOF



}
module "SG_PSG" {
  source        = "./modules/SG"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraform-postgres-access-sg"
  sg_description = "Security group for PostgreSQL access"

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow PostgreSQL access"
    }
  ]
}

/*data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "arn:aws:secretsmanager:us-east-1:800757917002:secret:MyPostgresPassword-yRbcHC"
}*/

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "MyPostgresPassword"
}

#mypostgrespassword
#psql -h -U dbadmin -d mydatabase

module "rds_postgres" {
  source                = "./modules/rds"
  db_name               = "mydatabase"
  db_subnet_group       = "my-db-subnet-group"
  subnet_ids            = module.vpc.private_subnet_ids
  allocated_storage     = 20
  engine                = "postgres"
  instance_class        = "db.t3.micro"
  username              = "dbadmin"
  password              = data.aws_secretsmanager_secret_version.db_password.secret_string
  parameter_group_name  = "default.postgres16"
  vpc_security_group_ids = [module.SG_PSG.security_group_id]
  multi_az              = false
  availability_zone     = "us-east-1a"
  apply_immediately     = true
  publicly_accessible   = true
  tags = {
    Name = "my-rds-instance"
  }
}





output "bastion_host_public_ip" {
  value = module.bastion_host.public_ip
}

output "private_server_private_ip" {
  value = module.private_server.private_ip
}

output "security_group_id" {
  value = module.SG_SSH.security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
