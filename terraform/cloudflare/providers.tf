provider "onepassword" {
  account = "my.1password.com"
}

provider "cloudflare" {
  api_token = ephemeral.onepassword_item.cloudflare.password
}
