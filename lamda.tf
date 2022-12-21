resource "aws_lambda_function" "spotify_api" {
  function_name    = "get-currently-playing-track"
  s3_bucket        = aws_s3_bucket.lambda_assets.bucket
  s3_key           = data.aws_s3_object.function.key
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  source_code_hash = data.aws_s3_object.function_hash.body
  runtime          = "nodejs16.x"
  timeout          = "10"
  layers           = [aws_lambda_layer_version.spotify_api_layer.arn]
  environment {
    variables = {
      SPOTIFY_REFRESH_TOKEN = var.SPOTIFY_REFRESH_TOKEN
      SPOTIFY_CLIENT_ID     = var.SPOTIFY_CLIENT_ID
      SPOTIFY_CLIENT_SECRET = var.SPOTIFY_CLIENT_SECRET
    }
  }
}

resource "aws_lambda_layer_version" "spotify_api_layer" {
  layer_name               = "spotify_api_layer"
  compatible_runtimes      = ["nodejs16.x"]
  compatible_architectures = ["x86_64"]
  s3_bucket                = aws_s3_bucket.lambda_assets.bucket
  s3_key                   = data.aws_s3_object.layer.key
  source_code_hash         = data.aws_s3_object.layer_hash.body
}

resource "aws_iam_role" "iam_for_lambda" {
  name                = "role-for-ts-lambda"
  assume_role_policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", ]
}

resource "null_resource" "lambda_build" {
  depends_on = [
    aws_s3_bucket.lambda_assets
  ]
  triggers = {
    code_diff = join("", [
      for file in fileset(local.spotify_function_dir_local_path, "{*.ts, package*.json}")
      : filebase64("${local.spotify_function_dir_local_path}/${file}")
    ])
  }

  // /spotify配下に./nodejsを作成し、package*.jsonをコピー後、/nodejs配下で npm install
  provisioner "local-exec" {
    command = "cd ./lambdas/spotify && mkdir -p nodejs && cp package*.json nodejs/ && npm install --prefix ./nodejs --production && mkdir -p layer_dist && zip -r -u ./layer_dist/layer.zip nodejs/node_modules && rm -r nodejs"
  }

  provisioner "local-exec" {
    command = "cd ${local.spotify_function_dir_local_path} && npm run build"
  }
  // function
  provisioner "local-exec" {
    command = "aws s3 cp ${local.spotify_function_package_local_path} s3://${aws_s3_bucket.lambda_assets.bucket}/${local.spotify_function_package_s3_key}"
  }
  provisioner "local-exec" {
    command = "openssl dgst -sha256 -binary ${local.spotify_function_package_local_path} | openssl enc -base64 | tr -d \"\n\" > ${local.spotify_function_package_base64sha256_local_path}"
  }
  provisioner "local-exec" {
    command = "aws s3 cp ${local.spotify_function_package_base64sha256_local_path} s3://${aws_s3_bucket.lambda_assets.bucket}/${local.spotify_function_package_base64sha256_s3_key} --content-type \"text/plain\""
  }

  // layer
  provisioner "local-exec" {
    command = "aws s3 cp ${local.spotify_layer_package_local_path} s3://${aws_s3_bucket.lambda_assets.bucket}/${local.spotify_layer_package_s3_key}"
  }
  provisioner "local-exec" {
    command = "openssl dgst -sha256 -binary ${local.spotify_layer_package_local_path} | openssl enc -base64 | tr -d \"\n\" > ${local.spotify_layer_package_base64sha256_local_path}"
  }
  provisioner "local-exec" {
    command = "aws s3 cp ${local.spotify_layer_package_base64sha256_local_path} s3://${aws_s3_bucket.lambda_assets.bucket}/${local.spotify_layer_package_base64sha256_s3_key} --content-type \"text/plain\""
  }
}


resource "aws_s3_bucket" "lambda_assets" {
  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_assets" {
  bucket = aws_s3_bucket.lambda_assets.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "labmda_assets" {
  bucket = aws_s3_bucket.lambda_assets.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_assets" {
  bucket                  = aws_s3_bucket.lambda_assets.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_s3_object" "function" {
  depends_on = [
    null_resource.lambda_build
  ]
  bucket = aws_s3_bucket.lambda_assets.bucket
  key    = local.spotify_function_package_s3_key
}

data "aws_s3_object" "function_hash" {
  depends_on = [null_resource.lambda_build]
  bucket     = aws_s3_bucket.lambda_assets.bucket
  key        = local.spotify_function_package_base64sha256_s3_key
}

data "aws_s3_object" "layer" {
  depends_on = [
    null_resource.lambda_build
  ]
  bucket = aws_s3_bucket.lambda_assets.bucket
  key    = local.spotify_layer_package_s3_key
}

data "aws_s3_object" "layer_hash" {
  depends_on = [
    null_resource.lambda_build
  ]
  bucket = aws_s3_bucket.lambda_assets.bucket
  key    = local.spotify_layer_package_base64sha256_s3_key
}
