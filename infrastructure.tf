provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_s3_bucket" "terraform" {
  bucket = "vip-sms-terraform"
  acl = "private"
}

resource "aws_s3_bucket" "development" {
  bucket = "vip-sms-development"
  acl = "private"
}

resource "aws_s3_bucket" "staging" {
  bucket = "vip-sms-staging"
  acl = "private"
}

resource "aws_s3_bucket" "production" {
  bucket = "vip-sms-production"
  acl = "private"
}

resource "aws_security_group" "main" {
  name = "vip-sms-app"
  description = "vip-sms-app"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "1" {
  name = "vip-sms-app-lb1"
  availability_zones= ["us-east-1a", "us-east-1c", "us-east-1d"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    timeout = 2
    healthy_threshold = 2
    unhealthy_threshold = 2
    target = "HTTP:80/status"
    interval = 10
  }

  instances = ["${aws_instance.web-1.id}", "${aws_instance.web-2.id}"]
}

resource "aws_instance" "web-staging" {
  ami = "${var.web_staging_ami}"
  instance_type = "m3.medium"
  availability_zone = "us-east-1a"
  key_name = "vip-sms"
  security_groups = ["${aws_security_group.main.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "vip-sms-app-staging-web"
  }
}

resource "aws_instance" "worker-staging" {
  ami = "${var.worker_staging_ami}"
  instance_type = "m3.medium"
  key_name = "vip-sms"
  security_groups = ["${aws_security_group.main.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "vip-sms-app-staging-worker"
  }
}

resource "aws_instance" "web-1" {
  ami = "${var.web_production_ami}"
  instance_type = "m3.medium"
  availability_zone = "us-east-1a"
  key_name = "vip-sms"
  security_groups = ["${aws_security_group.main.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "vip-sms-app-web"
  }
}

resource "aws_instance" "web-2" {
  ami = "${var.web_production_ami}"
  instance_type = "m3.medium"
  availability_zone = "us-east-1c"
  key_name = "vip-sms"
  security_groups = ["${aws_security_group.main.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "vip-sms-app-web"
  }
}

resource "aws_instance" "worker-1" {
  ami = "${var.worker_production_ami}"
  instance_type = "m3.medium"
  key_name = "vip-sms"
  security_groups = ["${aws_security_group.main.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "vip-sms-app-worker"
  }
}

resource "aws_instance" "worker-2" {
  ami = "${var.worker_production_ami}"
  instance_type = "m3.medium"
  key_name = "vip-sms"
  security_groups = ["${aws_security_group.main.name}"]
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "vip-sms-app-worker"
  }
}
