data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  key_name               = var.ssh_key_name
  associate_public_ip_address = true

  user_data = file("user_data.sh")

  iam_instance_profile = aws_iam_instance_profile.agent_profile.name

  tags = merge(var.common_tags, { Name = "azdo-self-hosted-agent" })
}

resource "aws_iam_role" "agent_role" {
  name = "azdo-agent-role-${random_id.rid.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "agent_ec2_attach" {
  role       = aws_iam_role.agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser" # allows pushing to ECR
}

resource "aws_iam_instance_profile" "agent_profile" {
  name = "azdo-agent-profile-${random_id.rid.hex}"
  role = aws_iam_role.agent_role.name
}

resource "random_id" "rid" {
  byte_length = 4
}