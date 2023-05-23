# Cognito User pool createion
resource "aws_cognito_user_pool" "userpool" {
  name = "${var.common_name}-userpool"
  
  username_attributes = [
    "email"
  ]
  
  auto_verified_attributes = [
    "email"
  ]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  schema {
    name = "email"
    attribute_data_type = "String"
    required = true
    mutable = true
  }
}

# Creating a user pool client
resource "aws_cognito_user_pool_client" "client" {
  name = "aws-ug-demo-client"
  user_pool_id = aws_cognito_user_pool.userpool.id
  
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = ["email", "openid", "aws.cognito.signin.user.admin"]
  callback_urls = [ aws_amplify_app.frontend.default_domain ]
}
