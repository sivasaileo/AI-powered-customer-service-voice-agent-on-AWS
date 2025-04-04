provider "aws" {
  region = var.aws_region
}

resource "aws_connect_instance" "connectinstance" {
  identity_management_type = "CONNECT_MANAGED"
  instance_alias           = "ReservationAssistant"
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true
}

resource "aws_connect_contact_flow" "connectcontactflow" {
  instance_id = aws_connect_instance.connectinstance.id
  name        = "ReservationFlow"
  content     = file("contact_flow.json")
}

resource "aws_lex_intent" "make_reservation" {
  name              = "MakeReservation"
  sample_utterances = ["I want to make a reservation", "Book a table for tonight"]

  fulfillment_activity {
    type = "CodeHook"
    code_hook {
      message_version = "1.0"
      uri             = aws_lambda_function.lambdafunction.arn
    }
  }
}

resource "aws_lex_bot" "lexbot" {
  name            = "ReservationBot"
  description     = "Bot for handling reservations"
  child_directed  = false
  voice_id        = "Joanna"
    locale          = "en-US"
  intent {
    intent_name    = aws_lex_intent.make_reservation.name
    intent_version = aws_lex_intent.make_reservation.version
  }

  abort_statement {
    message {
      content_type = "PlainText"
      content      = "Sorry, I couldn't understand. Please try again."
    }
  }
}

resource "aws_lambda_function" "lambdafunction" {
  function_name = "ProcessReservation"
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.iamrole.arn
  source_code_hash = filebase64sha256("C:/Users/ssandula/learnings/projects/AI-powered-customer-service-voice-agent-on-AWS/lambda/process_reservation.zip")
  filename         = "C:/Users/ssandula/learnings/projects/AI-powered-customer-service-voice-agent-on-AWS/lambda/process_reservation.zip"
}

resource "aws_iam_role" "iamrole" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "iamrolepolicyattachment" {
  role       = aws_iam_role.iamrole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_dynamodb_table" "dynamodbtable" {
  name           = "Reservations"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ReservationID"
  attribute {
    name = "ReservationID"
    type = "S"
  }
}

resource "aws_ses_domain_identity" "sesdomainidentity" {
  domain = "example.com"
}

resource "aws_ses_domain_dkim" "sesdomaindkim" {
  domain = aws_ses_domain_identity.sesdomainidentity.domain
}

resource "aws_ses_email_identity" "sesemailidentity" {
  email = "learningpractice999@gmail.com"
}
