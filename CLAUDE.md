# kube-saturn

Homelab Kubernetes cluster (Saturn) managed with Flux GitOps, Talos Linux, and Terraform.

## Cloudflare Zero Trust

All apps exposed via the Cloudflare Tunnel (`*.markmckessock.com`) are **publicly accessible by default**. Restricted apps must have explicit Zero Trust entries.

### When adding a new app

If the new app should be access-controlled:

1. Add a `cloudflare_access_application` and `cloudflare_access_policy` block to `terraform/cloudflare/zero_trust.tf`.
2. Reference the reusable `cloudflare_access_group.admin` group for owner-only access. Add additional groups/policies as needed for broader access.
3. Run a Terraform reconcile in the `terraform/cloudflare/` workspace to apply the changes.

If the app should be fully public, no Zero Trust entry is needed.

## Comments

Use comments sparingly — only where the code is not self-explanatory. Prefer making the
code clear over explaining unclear code.

99% of comments should be a single line. Reserve longer blocks for the rare case where a
non-obvious constraint genuinely cannot be stated in one, and never restate what the
code already says.
