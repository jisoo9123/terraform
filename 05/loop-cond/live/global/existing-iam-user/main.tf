provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_user" "createuser" {
  # Make sure to update this to your own user name!
  # count = length(var.user_names)
  for_each = toset(var.user_names)
  name = each.value
}

