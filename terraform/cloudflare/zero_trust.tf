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

resource "cloudflare_zero_trust_access_policy" "anonymous" {
  account_id = local.cloudflare_account_id
  name       = "Allow anyone"
  decision   = "bypass"

  include = [{
    everyone = {}
  }]
}

# ── Access Applications ────────────────────────────────────────────────────────
# Every exposed app needs an access_application; the wildcard default denies the rest.

resource "cloudflare_zero_trust_access_application" "jorkyfin" {
  account_id       = local.cloudflare_account_id
  name             = "Jorkyfin"
  domain           = "jorkyfin.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.anonymous.id
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

resource "cloudflare_zero_trust_access_application" "tandoor" {
  account_id       = local.cloudflare_account_id
  name             = "Tandoor"
  domain           = "tandoor.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "pelican" {
  account_id       = local.cloudflare_account_id
  name             = "Pelican"
  domain           = "pelican.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

# scanrr can trigger media deletion via the arr API — admin-only.
resource "cloudflare_zero_trust_access_application" "scanrr" {
  account_id       = local.cloudflare_account_id
  name             = "scanrr"
  domain           = "scanrr.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

# photoframe-webhook receives MMS webhooks from Twilio, which cannot log in to
# Cloudflare Access. Without an explicit bypass the catch-all application answers
# Twilio's POST with a 302 to the login page and Twilio reports "11200 HTTP
# retrieval failure".
#
# Bypassing the whole hostname is safe here: the HTTPRoute publishes only /mms, and
# the app authenticates every request itself by validating Twilio's X-Twilio-Signature
# against TWILIO_AUTH_TOKEN. The image endpoints are not routed publicly at all --
# they are served on a separate LAN-only LoadBalancer.
resource "cloudflare_zero_trust_access_application" "photoframe" {
  account_id       = local.cloudflare_account_id
  name             = "photoframe-webhook"
  domain           = "photoframe.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.anonymous.id
    precedence = 1
  }]
}

# Twilio cannot log in to Access, same as photoframe above. Safe to bypass: /sms rejects
# anything without a valid X-Twilio-Signature, and /latest is gated by kd_webhook_latest.
resource "cloudflare_zero_trust_access_application" "kd_webhook" {
  account_id       = local.cloudflare_account_id
  name             = "kd-webhook"
  domain           = "kd-webhook.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.anonymous.id
    precedence = 1
  }]
}

# The frame cannot log in, so it presents this token; the more specific path overrides the bypass above.
resource "cloudflare_zero_trust_access_service_token" "kd_frame" {
  account_id = local.cloudflare_account_id
  name       = "kd-frame"
  duration   = "forever"
}

resource "cloudflare_zero_trust_access_policy" "kd_frame" {
  account_id = local.cloudflare_account_id
  name       = "Allow kd-frame service token"
  decision   = "non_identity"

  include = [{
    service_token = {
      token_id = cloudflare_zero_trust_access_service_token.kd_frame.id
    }
  }]
}

resource "cloudflare_zero_trust_access_application" "kd_webhook_latest" {
  account_id       = local.cloudflare_account_id
  name             = "kd-webhook-latest"
  domain           = "kd-webhook.markmckessock.com/latest"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.kd_frame.id
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.admin.id
      precedence = 2
    },
  ]
}

resource "onepassword_item" "kd_frame_token" {
  vault      = var.onepassword_kubernetes_vault_id
  title      = "kd-webhook-frame-access"
  category   = "login"
  url        = "https://kd-webhook.markmckessock.com/latest"
  username   = cloudflare_zero_trust_access_service_token.kd_frame.client_id
  password   = cloudflare_zero_trust_access_service_token.kd_frame.client_secret
  note_value = "Send as CF-Access-Client-Id (username) and CF-Access-Client-Secret (password) headers."
}

# GitHub cannot log in to Access; only /hook/ is routed and the receiver path is the secret.
resource "cloudflare_zero_trust_access_application" "flux_webhook" {
  account_id       = local.cloudflare_account_id
  name             = "flux-webhook"
  domain           = "flux-webhook.markmckessock.com/hook"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.anonymous.id
    precedence = 1
  }]
}

# lidarr can trigger media deletion and exposes indexer credentials via the arr
# API — admin-only, matching scanrr.
# Cameras: tighter session and cookies than the 24h default.
resource "cloudflare_zero_trust_access_application" "frigate" {
  account_id                 = local.cloudflare_account_id
  name                       = "Frigate"
  domain                     = "frigate.markmckessock.com"
  session_duration           = "1h"
  type                       = "self_hosted"
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "lax"
  enable_binding_cookie      = true

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "lidarr" {
  account_id       = local.cloudflare_account_id
  name             = "Lidarr"
  domain           = "lidarr.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

# Location history is sensitive: the web UI is admin-only.
resource "cloudflare_zero_trust_access_application" "dawarich" {
  account_id       = local.cloudflare_account_id
  name             = "Dawarich"
  domain           = "dawarich.markmckessock.com"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.admin.id
    precedence = 1
  }]
}

# Phone trackers (Dawarich iOS, OwnTracks, Overland) can't log in to Access; /api requires a Dawarich API key.
resource "cloudflare_zero_trust_access_application" "dawarich_api" {
  account_id       = local.cloudflare_account_id
  name             = "Dawarich API"
  domain           = "dawarich.markmckessock.com/api"
  session_duration = "24h"
  type             = "self_hosted"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.anonymous.id
    precedence = 1
  }]
}
