resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.common_name}-apigateway"
  description = "Apigateway for demo"
  endpoint_configuration {
    types            = ["REGIONAL"]
  }
}

#Create VPC link
resource "aws_api_gateway_vpc_link" "vpclink" {
  name        = "${var.common_name}-tonlb"
  description = "VPC link"
  target_arns = [aws_lb.nlb.arn]
}


#Create Authorizer configuration
resource "aws_api_gateway_authorizer" "api_auth" {
  name          = "aws-ug-demo"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  provider_arns = aws_cognito_user_pool.userpool.arn
}

#Create resources 
resource "aws_api_gateway_resource" "resource_market" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "market"
}

resource "aws_api_gateway_resource" "resource_text" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "text"
}

resource "aws_api_gateway_resource" "resource_video" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "video"
}



#Create methods requests
## MARKET endpoint
resource "aws_api_gateway_method" "get_market_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_market.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "get_market_request_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource_market.id
  http_method             = aws_api_gateway_method.get_market_request.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://aws-ug-am-demo-lb-012629af33356489.elb.us-west-1.amazonaws.com/market"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpclink.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method" "market_options_method" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    resource_id   = aws_api_gateway_resource.resource_market.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

## VIDEO endpoint
resource "aws_api_gateway_method" "get_video_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_video.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "get_video_request_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_video.id
  http_method = aws_api_gateway_method.get_video_request.http_method
  integration_http_method = "GET"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.lambda_1_function.invoke_arn
}

## TEXT endpoint
resource "aws_api_gateway_method" "get_text_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_text.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "get_text_request_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_text.id
  http_method = aws_api_gateway_method.get_text_request.http_method
  integration_http_method = "POST"
  type        = "AWS"
  uri         = "arn:aws:apigateway:us-west-1:dynamodb:action/Query"
  request_templates = {
    "application/json" = <<EOF
      {
        "TableName": "${aws_dynamodb_table.basic-dynamodb-table.name}",
        "KeyConditionExpression": "id = :id",
        "PrimaryKey": "id",
        "ExpressionAttributeValues": {
          ":id": {
              "S": "$input.params('id')"
          }
        }
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "get_text_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_text.id
  http_method = aws_api_gateway_method.get_text_request.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_text_response_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_text.id
  http_method = aws_api_gateway_method.get_text_request.http_method
  status_code = aws_api_gateway_method_response.get_text_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = <<EOF
      #set($inputRoot = $input.path('$'))
      #foreach($elem in $inputRoot.Items)
      {
          "id": "$elem.id.S",
          "text": "$elem.text.S"
      }#if($foreach.hasNext),#end
      #end
    EOF
  }
}



resource "aws_api_gateway_method" "post_text_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_text.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "post_text_request_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_text.id
  http_method = aws_api_gateway_method.get_text_request.http_method
  integration_http_method = "POST"
  type        = "AWS"
  uri         = "arn:aws:apigateway:us-west-1:dynamodb:action/PutItem"
  request_templates = {
    "application/json" = <<EOF
      { 
          "TableName": "${aws_dynamodb_table.basic-dynamodb-table.name}",
          "Item": {
              "id": {
                  "S": "$input.path('$.id')"
                  },
              "text": {
                  "S": "$input.path('$.text')"
              }
          }
      }
    EOF
  }
}


#Deployment configuration
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Stage definition
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"

  xray_tracing_enabled = true
}

resource "aws_api_gateway_method_settings" "dev_settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled               = true
    data_trace_enabled            = true
    logging_level                 = "ERROR"
    throttling_burst_limit        = 5000
    throttling_rate_limit         = 10000

  }
}

