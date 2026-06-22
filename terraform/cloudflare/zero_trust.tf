data "cloudflare_accounts" "me" {}

locals {
  cloudflare_account_id = data.cloudflare_accounts.me.result[0].id
}

# ── Reusable Groups ────────────────────────────────────────────────────────────

resource "cloudflare_zero_trust_access_group" "admin" {
  account_id = local.cloudflare_account_id
  name       = "Allow admin"

  include = [{
    email = {
      email = "mark.mckessock@gmail.com"
    }
  }]
}

# ── Reusable Policies ──────────────────────────────────────────────────────────
# Account-level policies — referenced by applications via policies[].id.
# Add new policies here when broader access is needed (e.g. family, guests).

resource "cloudflare_zero_trust_access_policy" "admin" {
  account_id = local.cloudflare_account_id
  name       = "Allow admin"
  decision   = "allow"

  include = [{
    group = {
      id = cloudflare_zero_trust_access_group.admin.id
    }
  }]
}

# ── Access Applications ────────────────────────────────────────────────────────
# Each restricted app needs an access_application referencing one or more
# reusable policies. Public apps need no entry here.

resource "cloudflare_zero_trust_access_application" "fileflows" {
  account_id       = local.cloudflare_account_id
  name             = "FileFlows"
  domain           = "fileflows.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "maintainerr" {
  account_id       = local.cloudflare_account_id
  name             = "Maintainerr"
  domain           = "maintainerr.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}
