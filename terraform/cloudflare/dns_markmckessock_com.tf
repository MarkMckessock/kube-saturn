data "cloudflare_zones" "public_domain" {
  filter {
    name = "markmckessock.com"
  }
}

resource "cloudflare_record" "host_rpi" {
  name    = "rpi-ha.infra"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.60.20"
  proxied = false
  type    = "A"
  ttl     = 1
}


resource "cloudflare_record" "host_kari" {
  name    = "kari.saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.2"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "saturn_cluster" {
  name    = "saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.5"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "host_titan" {
  name    = "titan.saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.3"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "host_phoebe" {
  name    = "phoebe.saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.4"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "host_hyperion" {
  name    = "hyperion.saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.5"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "host_janus" {
  name    = "janus.saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.7"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "host_tarvos" {
  name    = "tarvos.saturn.kube"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.9"
  proxied = false
  type    = "A"
  ttl     = 1
}


resource "cloudflare_record" "host_granite" {
  name    = "granite"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.8"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "mosquitto" {
  name    = "mosquitto"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = "10.0.70.131"
  proxied = false
  type    = "A"
  ttl     = 1
}
