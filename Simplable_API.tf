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

//creating API 
resource "aws_api_gateway_rest_api" "External_API" {
  name        = "External_API"
  description = "This is my API for demonstration purposes"
   endpoint_configuration {
    types = ["REGIONAL"]
  }
}

////creating resource of t&c 
resource "aws_api_gateway_resource" "terms_conditions" {
  depends_on  = [aws_api_gateway_rest_api.External_API]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_rest_api.External_API.root_resource_id
  path_part   = "terms-conditions"
}
///get method of t&c///
resource "aws_api_gateway_method" "terms_condition" {
  depends_on  = [aws_api_gateway_resource.terms_conditions]
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.terms_conditions.id
  http_method   = "GET"
  authorization = "NONE"
}

////API integration of t&c
resource "aws_api_gateway_integration" "terms_conditionsIntegration" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.terms_conditions.id
  http_method = aws_api_gateway_method.terms_condition.http_method
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}

////creating resource verion1 
resource "aws_api_gateway_resource" "version1" {
  depends_on  = [aws_api_gateway_rest_api.External_API]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_rest_api.External_API.root_resource_id
  path_part   = "v1"
}

//creating resource auth
resource "aws_api_gateway_resource" "auth" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.version1.id
  path_part   = "auth"
}

//creating resource token
resource "aws_api_gateway_resource" "token" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "token"
}

////post method for token
resource "aws_api_gateway_method" "token_post" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.token.id
  http_method   = "POST"
  authorization = "NONE"
}

///cors for token
resource "aws_api_gateway_method" "token_options" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.token.id
  http_method   = "OPTIONS"
  authorization = "NONE"                  
}
///integration of version1
resource "aws_api_gateway_integration" "tokenIntegration" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.token.id
  http_method = aws_api_gateway_method.token_post.http_method
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}

//creating resource buyer
resource "aws_api_gateway_resource" "buyer" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.version1.id
  path_part   = "buyer"
}

//creating resource orders
resource "aws_api_gateway_resource" "orders" {
  depends_on  = [aws_api_gateway_resource.buyer]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.buyer.id
  path_part   = "orders"
}

///cors for orders
resource "aws_api_gateway_method" "orders_options" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "OPTIONS"
  authorization = "NONE"                  
}
//post method for orders
resource "aws_api_gateway_method" "orders_post" {
  depends_on  = [aws_api_gateway_resource.buyer]
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = "NONE"
}

//creating resource po_numbers
resource "aws_api_gateway_resource" "po_number" {
  depends_on  = [aws_api_gateway_resource.buyer]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.orders.id
  path_part   = "{po_number}"
}

///get method for po number
resource "aws_api_gateway_method" "po_number_get" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.po_number.id
  http_method   = "GET"
  authorization = "NONE"
}
///cors for po_numbers
resource "aws_api_gateway_method" "ponumber_options" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.po_number.id
  http_method   = "OPTIONS"
  authorization = "NONE"                  
}

 /// API integration of orders ////
resource "aws_api_gateway_integration" "orders_post" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method = aws_api_gateway_method.orders_post.http_method
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}

 /// API integration of po_number ////
resource "aws_api_gateway_integration" "po_order_get" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.po_number.id
  http_method = aws_api_gateway_method.po_number_get.http_method
  type = "AWS"
  integration_http_method = "GET"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}

////creating resource seller
resource "aws_api_gateway_resource" "seller" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.version1.id
  path_part   = "seller"

}

//creating resource seller orders
resource "aws_api_gateway_resource" "sell_orders" {
  depends_on  = [aws_api_gateway_resource.seller]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.seller.id
  path_part   = "orders"
}

//creating resource seller po_number_seller
resource "aws_api_gateway_resource" "po_number_new" {
  depends_on  = [aws_api_gateway_resource.seller]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.sell_orders.id
  path_part   = "{po_number}"
}

//creating resource claim
resource "aws_api_gateway_resource" "claim" {
  depends_on  = [aws_api_gateway_resource.seller]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.po_number_new.id
  path_part   = "claim"
}

///cors for claim
resource "aws_api_gateway_method" "claim_options" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.claim.id
  http_method   = "OPTIONS"
  authorization = "NONE"                  
}

//creating method for claim
resource "aws_api_gateway_method" "claim_post" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.claim.id
  http_method   = "POST"
  authorization = "NONE"
}

///integration of claim
resource "aws_api_gateway_integration" "claimIntegration" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.claim.id
  http_method = aws_api_gateway_method.claim_post.http_method
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}

//// invoice-upload-url
resource "aws_api_gateway_resource" "invoice_upload" {
  depends_on  = [aws_api_gateway_resource.seller]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.po_number_new.id
  path_part   = "invoice-upload-url"
}

//method for invouce url
resource "aws_api_gateway_method" "invoiceupload_get" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.invoice_upload.id
  http_method   = "GET"
  authorization = "NONE"
}

///integration of invoice upload
resource "aws_api_gateway_integration" "invoiceuploadIntegration" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.invoice_upload.id
  http_method = aws_api_gateway_method.invoiceupload_get.http_method
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}

//creating resource available
resource "aws_api_gateway_resource" "available" {
  depends_on  = [aws_api_gateway_resource.seller]
  rest_api_id = aws_api_gateway_rest_api.External_API.id
  parent_id   = aws_api_gateway_resource.sell_orders.id
  path_part   = "available"
}

//creating method for available
resource "aws_api_gateway_method" "available_get" {
  depends_on  = [aws_api_gateway_resource.version1]
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.available.id
  http_method   = "GET"
  authorization = "NONE"
}

///cors for available
resource "aws_api_gateway_method" "available_options" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.available.id
  http_method   = "OPTIONS"
  authorization = "NONE"                  
}

///integration of invoice upload
resource "aws_api_gateway_integration" "availableitemsIntegration" {
  rest_api_id   = aws_api_gateway_rest_api.External_API.id
  resource_id   = aws_api_gateway_resource.available.id
  http_method = aws_api_gateway_method.available_get.http_method
  type = "AWS"
  integration_http_method = "GET"
  uri = "arn:aws:apigateway:ap-south-1:sqs:path/aws_sqs_queue.Rads_Queue.name"
  credentials = "arn:aws:iam::714394906614:role/radhika_API_SQS"  # IAM Role ARN with SQS permissions
}