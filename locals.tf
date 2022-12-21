locals {
  spotify_function_dir_local_path                  = "./lambdas/spotify"
  spotify_function_package_local_path              = "./lambdas/spotify/dist/index.zip"
  spotify_function_package_base64sha256_local_path = "./lambdas/spotify/dist/index.zip.base64sha256"
  spotify_function_package_s3_key                  = "spotify/index.zip"
  spotify_function_package_base64sha256_s3_key     = "${local.spotify_function_package_s3_key}.base64sha256.txt"
}

locals {
  spotify_layer_dir_local_path                  = "./lambdas/spotify/nodejs/node_moduels"
  spotify_layer_package_local_path              = "./lambdas/spotify/layer_dist/layer.zip"
  spotify_layer_package_base64sha256_local_path = "./lambdas/spotify/layer_dist/layer.zip.base64sha256"
  spotify_layer_package_s3_key                  = "spotify/layer.zip"
  spotify_layer_package_base64sha256_s3_key     = "${local.spotify_layer_package_s3_key}.base64sha256.txt"
}
