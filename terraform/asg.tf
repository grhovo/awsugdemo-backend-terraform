# Create a launch template for the Auto Scaling Group
resource "aws_launch_template" "ec2_template" {
  name_prefix = "${var.common_name}-lt"
  image_id = "ami-0149d19be5d41b13c"
  instance_type = "t2.micro"
  key_name = "hovo-sandbox"
  #security_group_ids = [ aws_security_group.security_group.id ]
}

# Create an Auto Scaling Group using the launch template
resource "aws_autoscaling_group" "asg" {
  name = "${var.common_name}-asg"
  vpc_zone_identifier = [ data.aws_subnet.private_subnet_1.id, data.aws_subnet.private_subnet_2.id ]
  launch_template {
    id = aws_launch_template.ec2_template.id
    version = "$Latest"
  }
  min_size = 2
  max_size = 4
  desired_capacity = 2
}

# Create security group
resource "aws_security_group" "security_group" {
  name_prefix = "${var.common_name}-sg-ec2"
  
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}
