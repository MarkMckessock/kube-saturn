#!/usr/bin/env bash
# Catch ganymede early in boot and wipe EPHEMERAL before kubelet can wedge again.
#
# The problem: kubelet comes up unhealthy (its state on EPHEMERAL was corrupted by the
# disk failure) and then will not respond to SIGTERM, so Talos's reset sequence hangs
# forever at "stopAllPods: waiting for kubelet lifecycle finalizers". Any reset issued
# after that point returns "reset failed: locked".
#
# The fix is timing: right after boot the Talos API is up but kubelet has not started,
# so the reset sequence has nothing to get stuck on. That window is ~20-40s, which is
# why this polls rather than asking you to type fast.
#
# Usage: run this, THEN power cycle the node.
set -uo pipefail
cd "$(dirname "$0")"
export TALOSCONFIG=./talosconfig
NODE=10.0.70.65

echo "waiting for $NODE to go down..."
while ping -c1 -W1000 "$NODE" >/dev/null 2>&1; do sleep 2; done
echo "  down. waiting for the Talos API to come back..."

while true; do
  if timeout 5 talosctl -e "$NODE" -n "$NODE" version --short >/dev/null 2>&1; then
    echo "  API up -- firing reset immediately"
    break
  fi
  sleep 1
done

talosctl -e "$NODE" -n "$NODE" reset \
  --graceful=false --reboot --system-labels-to-wipe EPHEMERAL --wait=false
echo "reset issued. watch with:  talosctl -e $NODE -n $NODE dmesg | tail"
