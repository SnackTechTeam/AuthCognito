data "aws_iam_role" "voclabs" {
  name = "voclabs"
}

resource "aws_iam_role" "voclabs" {
  name = "voclabs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::117530877863:root",
            "arn:aws:iam::892797552725:root"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  max_session_duration = 43200
}