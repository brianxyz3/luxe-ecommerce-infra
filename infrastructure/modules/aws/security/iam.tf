resource "aws_iam_role" "ecs-exec-role" {
  name = "LuxeAppECSExecRole"

  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "sts:AssumeRole",
          Principal : {
            Service : "ecs-tasks.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "attach-exec-perm" {
  role       = aws_iam_role.ecs-exec-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}