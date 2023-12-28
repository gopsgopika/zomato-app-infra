## Resource INSTANCE ##
resource "aws_instance" "shopping_app" {

  ami                    = data.aws_ami.latest.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.app_key.key_name
  vpc_security_group_ids = [aws_security_group.http_access.id]
  tags = {
    Name    = "${var.project_name}-${var.project_env}-frontend"
    project = var.project_name
    env     = var.project_env
    owner   = var.project_own
  }
  lifecycle {
    create_before_destroy = true
  }
}

## Resource KEYPAIR ##

resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("appkey.pub")
  tags = {
    Name    = "${var.project_name}-${var.project_env}"
    project = var.project_name
    env     = var.project_env
    owner   = var.project_own
  }
}

## Resource SECURITY GROUP ##

resource "aws_security_group" "http_access" {
  name        = "${var.project_name}-${var.project_env}"
  description = "${var.project_name}-${var.project_env}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_env}-sg"
    project = var.project_name
    env     = var.project_env
    owner   = var.project_own
  }
}
##ROUTE53 RECORD##
resource "aws_route53_record" "shopping-app" {
  zone_id = var.hosted_zone_id
  name    = "${var.hostname}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 100
  records = [aws_instance.shopping_app.public_ip]
}
