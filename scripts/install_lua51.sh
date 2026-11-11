#!/usr/bin/env bash
# Build the exact test interpreter without depending on Ubuntu APT mirrors.
set -euo pipefail
install_root="${1:?Usage: install_lua51.sh ABSOLUTE_INSTALL_DIRECTORY}"
[[ "$install_root" = /* ]] || { echo 'Install directory must be absolute' >&2; exit 1; }
build_root="$(mktemp -d)"
trap 'rm -rf "$build_root"' EXIT
curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' \
  --connect-timeout 15 --max-time 90 --retry 2 \
  https://www.lua.org/ftp/lua-5.1.5.tar.gz -o "$build_root/lua.tar.gz"
printf '%s  %s\n' 2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333 \
  "$build_root/lua.tar.gz" | sha256sum --check --strict
tar -xzf "$build_root/lua.tar.gz" -C "$build_root"
# The generic target only needs the runner's C compiler, make and system math library.
make -C "$build_root/lua-5.1.5" generic
mkdir -p "$install_root/bin"
cp "$build_root/lua-5.1.5/src/lua" "$install_root/bin/lua5.1"
cp "$build_root/lua-5.1.5/src/luac" "$install_root/bin/luac5.1"
"$install_root/bin/lua5.1" -v
"$install_root/bin/luac5.1" -v
if [[ -n "${GITHUB_PATH:-}" ]]; then printf '%s\n' "$install_root/bin" >> "$GITHUB_PATH"; fi
