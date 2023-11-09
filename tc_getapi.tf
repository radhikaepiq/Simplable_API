terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}
provider "aws" {
  region = "ap-south-1"
}
resource "aws_api_gateway_rest_api" "RadDemoAPI" {
  name        = "RadDemoAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "RadDemoResource" {
  depends_on  = [aws_api_gateway_rest_api.RadDemoAPI]
  rest_api_id = aws_api_gateway_rest_api.RadDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.RadDemoAPI.root_resource_id
  path_part   = "terms-conditions"
}

///get///
resource "aws_api_gateway_method" "RadDemoMethod" {
  depends_on  = [aws_api_gateway_resource.RadDemoResource]
  rest_api_id   = aws_api_gateway_rest_api.RadDemoAPI.id
  resource_id   = aws_api_gateway_resource.RadDemoResource.id
  http_method   = "GET"
  authorization = "NONE"
}
