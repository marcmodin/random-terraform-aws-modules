variable "name_prefix" {
  type        = string
  description = "description"
}

# Instance Profile
resource "aws_iam_role" "default" {
  name_prefix = format("%s", var.name_prefix)
  path        = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "default" {
  name_prefix = format("%s-profile", aws_iam_role.default.name)
  role        = aws_iam_role.default.name
}

output "id" {
  value = aws_iam_instance_profile.default.id
}
