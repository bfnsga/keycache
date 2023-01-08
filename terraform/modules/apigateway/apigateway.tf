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
  integration_http_method = "POST"
  uri         = "arn:aws:apigateway:us-east-2:dynamodb:action/PutItem"
  request_templates = {
    "application/json" = <<EOF
{
  "TableName": "example",
  "Item": {
    "id": {
      "S": "${uuid()}"
    },
    "name": {
      "S": "testing"
    }
  }
}
EOF
  }
}