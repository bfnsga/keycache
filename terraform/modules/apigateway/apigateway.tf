#########################
## API Gateway
#########################

## API Account
#########################

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

## IAM Role
#########################
resource "aws_iam_role" "apigateway_role" {
  name        = "APIGatewayBaseRole"
  description = "Allows API Gateway to access AWS resources."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "apigateway_policy" {
  name        = "APIGatewayBasePolicy"
  description = "Allows API Gateway to access AWS resources."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "dynamodb:PutItem"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_role_policy" {
  role       = aws_iam_role.apigateway_role.name
  policy_arn = aws_iam_policy.apigateway_policy.arn
}

## API Gateway
#########################
resource "aws_api_gateway_rest_api" "example" {
  name = "example"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "example" {
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
  rest_api_id = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_method" "example" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  type        = "AWS"
  credentials = aws_iam_role.apigateway_role.arn
  integration_http_method = "POST"
  uri         = "arn:aws:apigateway:us-east-2:dynamodb:action/PutItem"
  passthrough_behavior    = "NEVER"

  request_templates = {
    "application/json" = <<EOF
#set($hello = $util.escapeJavaScript($input.json('$')))
{
  "TableName": "example",
  "Item": {
    "TestTableHashKey": {
      "S": "$context.requestId"
    },
    #foreach($key in $hello.keySet())
    "$key": {
        "S": "$hello.get($key)"
    }
      #if( $foreach.hasNext ), #end
   #end
    "name": {
      "S": "$hello"
    },
    "created_at": {
        "S": "$context.requestTimeEpoch"
    }
  }
}
EOF
  }
}

# Create a method response
resource "aws_api_gateway_method_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

# Create an integration response
resource "aws_api_gateway_integration_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_integration.example.http_method
  status_code = aws_api_gateway_method_response.example.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "'application/json'"
  }

  response_templates = {
    "application/json" = "{\"message\": \"Item added to DynamoDB table\"}"
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "example" {

  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "example"
}

resource "aws_api_gateway_method_settings" "path_specific" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.example.stage_name
  method_path = "*/*"

  settings {
    logging_level   = "INFO"
  }
}