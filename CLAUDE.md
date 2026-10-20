# kube-saturn

Homelab Kubernetes cluster (Saturn) managed with Flux GitOps, Talos Linux, and Terraform.

## Cloudflare Zero Trust

All apps exposed via the Cloudflare Tunnel (`*.markmckessock.com`) are **locked down by default**: a wildcard
`*.markmckessock.com` Access application with no policies denies any hostname without its own entry.
Very few apps should be public, and each one needs an explicit Zero Trust entry to be reachable at all.

### When adding a new app

Every externally exposed app needs a `cloudflare_zero_trust_access_application` in `terraform/cloudflare/zero_trust.tf`:

1. Default to the reusable `admin` policy (backed by `cloudflare_zero_trust_access_group.admin`) for owner-only access. Add groups/policies only when broader access is genuinely needed.
2. Use the `anonymous` (bypass) policy only for apps that must be public, e.g. webhook receivers called by third parties. Confirm with the owner before making anything public.
3. Run a Terraform reconcile in the `terraform/cloudflare/` workspace to apply the changes.

## Comments

Use comments sparingly — only where the code is not self-explanatory. Prefer making the
code clear over explaining unclear code.

99% of comments should be a single line. Reserve longer blocks for the rare case where a
non-obvious constraint genuinely cannot be stated in one, and never restate what the
code already says.
