terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "markmckessock"
    workspaces {
      name = "arpa-home-cloudflare"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.21.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.2"
    }
  }
  required_version = ">= 1.10.0"
}

# Ephemeral resources are never written to Terraform state.
# Requires `op` CLI to be signed in before running terraform plan/apply.
ephemeral "onepassword_item" "cloudflare" {
  vault = var.onepassword_kubernetes_vault_id
  title = "cloudflare-terraform"
}
