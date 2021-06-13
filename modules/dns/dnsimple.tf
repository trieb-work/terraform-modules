provider "dnsimple" {
  token   = var.token
  account = var.account
}


resource "dnsimple_record" "dashboard" {
  domain = var.domain
  name   = var.name
  value  = "cname.vercel-dns.com"
  type   = "CNAME"
  ttl    = 3600
}

resource "dnsimple_record" "dashboard_txt" {
  domain = var.domain
  name   = var.name
  value  = "heritage=terraform-for-vercel"
  type   = "TXT"
  ttl    = 3600
}
