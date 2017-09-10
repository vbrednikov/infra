provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "aws_ami" "reddit_base_ami" {
  most_recent = true
  name_regex="^reddit-base-.*"
  owners = ["self"]
}


resource "aws_security_group" "reddit_app" {
  name        = "reddit_app"
  description = "Allow inbound connections to TCP:9292 (puma server) and TCP:22 (ssh)"

  #  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 9292
    from_port   = 9292
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.aws_public_key_path)}"
}

resource "aws_instance" "reddit_app" {
  connection {
    user = "ubuntu"
  }

  security_groups = ["${aws_security_group.reddit_app.name}"]
  instance_type   = "t2.micro"
  ami             = "${data.aws_ami.reddit_base_ami.id}"
  key_name        = "${aws_key_pair.auth.id}"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    agent       = false
    private_key = "${file(var.aws_private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

