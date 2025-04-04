output "connect_instance_id" {
  value = aws_connect_instance.connectinstance
}

output "lex_bot_name" {
  value = aws_lex_bot.lexbot
}

output "lambda_function_name" {
  value = aws_lambda_function.lambdafunction.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.dynamodbtable.name
}

output "ses_domain_identity" {
  value = aws_ses_domain_identity.sesdomainidentity.domain
}
