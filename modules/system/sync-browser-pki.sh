set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-browser-pki [--dry-run] [--purge]
                        [--ca-directory PATH]
                        [--smartcard-directory PATH]
                        [--nssdb PATH ...]

Synchronize locally managed certificate authorities into Chrome's NSS
database. Chrome and Chromium must be closed unless --dry-run is used.

  --dry-run                    Show the planned changes without modifying NSS.
  --purge                      Remove all certificates managed by this tool.
  --ca-directory PATH          Directory of certificates to trust as TLS roots.
  --smartcard-directory PATH   Directory of DoD/smartcard certificate bundles.
  --nssdb PATH                 NSS database to synchronize; may be repeated.
  -h, --help                   Show this help.

Environment overrides:
  BROWSER_PKI_ROOT
  BROWSER_CA_DIRECTORY
  SMARTCARD_PKI_DIRECTORY
  BROWSER_NSS_DATABASES        Colon-separated database paths.
EOF
}

die() {
  printf 'sync-browser-pki: %s\n' "$*" >&2
  exit 1
}

dry_run=false
purge=false
pki_root="${BROWSER_PKI_ROOT:-$HOME/Codez/dotfiles/assets/pki}"
ca_directory="${BROWSER_CA_DIRECTORY:-$pki_root/certificate-authorities}"
smartcard_directory="${SMARTCARD_PKI_DIRECTORY:-$pki_root/smartcard}"
declare -a requested_databases=()

while (($# > 0)); do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    --purge)
      purge=true
      shift
      ;;
    --ca-directory)
      (($# >= 2)) || die '--ca-directory requires a path'
      ca_directory="$2"
      shift 2
      ;;
    --smartcard-directory)
      (($# >= 2)) || die '--smartcard-directory requires a path'
      smartcard_directory="$2"
      shift 2
      ;;
    --nssdb)
      (($# >= 2)) || die '--nssdb requires a path'
      requested_databases+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

if ! $dry_run && [[ "${BROWSER_PKI_SKIP_BROWSER_CHECK:-0}" != 1 ]]; then
  for process_name in chrome chromium google-chrome brave brave-browser vivaldi; do
    if pgrep -x "$process_name" >/dev/null 2>&1; then
      die 'close Chrome/Chromium-family browsers before synchronizing certificates'
    fi
  done
fi

work_directory="$(mktemp -d)"
trap 'rm -rf -- "$work_directory"' EXIT
mkdir -p "$work_directory/certificates" "$work_directory/extracted"

declare -A desired_file=()
declare -A desired_trust=()
declare -A desired_subject=()
certificate_sequence=0
local_anchor_count=0
smartcard_anchor_count=0
smartcard_intermediate_count=0

record_certificate() {
  local source_kind="$1"
  local source_certificate="$2"
  local normalized fingerprint nickname trust subject issuer

  ((certificate_sequence += 1))
  normalized="$work_directory/certificates/certificate-$certificate_sequence.pem"
  openssl x509 -in "$source_certificate" -outform PEM -out "$normalized" \
    || die "could not normalize certificate extracted from $source_certificate"

  fingerprint="$(
    openssl x509 -in "$normalized" -noout -fingerprint -sha256 \
      | cut -d= -f2 \
      | tr -d ':'
  )"
  [[ "$fingerprint" =~ ^[[:xdigit:]]{64}$ ]] \
    || die "could not calculate a SHA-256 fingerprint for $source_certificate"

  subject="$(openssl x509 -in "$normalized" -noout -subject -nameopt RFC2253)"
  issuer="$(openssl x509 -in "$normalized" -noout -issuer -nameopt RFC2253)"
  subject="${subject#subject=}"
  issuer="${issuer#issuer=}"
  subject="${subject//$'\t'/ }"

  case "$source_kind" in
    local)
      nickname="dotfiles-local-ca-$fingerprint"
      trust='C,,'
      ;;
    smartcard)
      # Preserve the original nickname scheme so existing DoD entries become
      # managed automatically on the first reconciliation.
      nickname="smartcard-$fingerprint"
      if [[ "$subject" == "$issuer" ]]; then
        trust='C,,'
      else
        trust=',,'
      fi
      ;;
    *)
      die "internal error: unknown certificate source $source_kind"
      ;;
  esac

  if [[ -v "desired_file[$nickname]" ]]; then
    return
  fi

  if [[ "$source_kind" == local ]]; then
    ((local_anchor_count += 1))
  elif [[ "$trust" == 'C,,' ]]; then
    ((smartcard_anchor_count += 1))
  else
    ((smartcard_intermediate_count += 1))
  fi

  desired_file["$nickname"]="$normalized"
  desired_trust["$nickname"]="$trust"
  desired_subject["$nickname"]="$subject"
}

extract_pem_certificates() {
  local source_kind="$1"
  local pem_bundle="$2"
  local extraction_directory="$3"
  local extracted before

  mkdir -p "$extraction_directory"
  awk -v directory="$extraction_directory" '
    /-----BEGIN CERTIFICATE-----/ {
      file = sprintf("%s/certificate-%03d.pem", directory, ++count)
      writing = 1
    }
    writing { print > file }
    /-----END CERTIFICATE-----/ {
      close(file)
      writing = 0
    }
    END {
      if (writing) exit 2
    }
  ' "$pem_bundle" || die "malformed PEM certificate bundle: $pem_bundle"

  before=$certificate_sequence
  while IFS= read -r -d '' extracted; do
    record_certificate "$source_kind" "$extracted"
  done < <(find "$extraction_directory" -maxdepth 1 -type f -print0 | sort -z)

  ((certificate_sequence > before)) \
    || die "no certificates found in $pem_bundle"
}

extract_source_file() {
  local source_kind="$1"
  local source_file="$2"
  local extraction_directory pkcs7_output der_certificate

  if grep -aEq -- '-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY-----' "$source_file"; then
    die "private keys are not accepted: $source_file"
  fi

  ((source_file_sequence += 1))
  extraction_directory="$work_directory/extracted/source-$source_file_sequence"

  if grep -aFq -- '-----BEGIN CERTIFICATE-----' "$source_file"; then
    extract_pem_certificates "$source_kind" "$source_file" "$extraction_directory"
    return
  fi

  pkcs7_output="$work_directory/extracted/pkcs7-$source_file_sequence.pem"
  if openssl pkcs7 -inform DER -in "$source_file" -print_certs \
    -out "$pkcs7_output" 2>/dev/null \
    || openssl pkcs7 -inform PEM -in "$source_file" -print_certs \
      -out "$pkcs7_output" 2>/dev/null; then
    extract_pem_certificates "$source_kind" "$pkcs7_output" "$extraction_directory"
    return
  fi

  der_certificate="$work_directory/extracted/der-$source_file_sequence.pem"
  if openssl x509 -inform DER -in "$source_file" -outform PEM \
    -out "$der_certificate" 2>/dev/null; then
    record_certificate "$source_kind" "$der_certificate"
    return
  fi

  die "unsupported or malformed certificate file: $source_file"
}

source_file_sequence=0
if ! $purge; then
  [[ -d "$ca_directory" ]] \
    || die "CA directory is missing; refusing cleanup: $ca_directory"
  [[ -d "$smartcard_directory" ]] \
    || die "smartcard directory is missing; refusing cleanup: $smartcard_directory"

  while IFS= read -r -d '' source_file; do
    extract_source_file local "$source_file"
  done < <(find "$ca_directory" -maxdepth 1 -type f -print0 | sort -z)

  while IFS= read -r -d '' source_file; do
    extract_source_file smartcard "$source_file"
  done < <(find "$smartcard_directory" -maxdepth 1 -type f -print0 | sort -z)
fi

declare -a databases=()
if ((${#requested_databases[@]} > 0)); then
  databases=("${requested_databases[@]}")
elif [[ -n "${BROWSER_NSS_DATABASES:-}" ]]; then
  IFS=: read -r -a databases <<<"$BROWSER_NSS_DATABASES"
else
  databases+=("$HOME/.pki/nssdb")
  legacy_database="${XDG_DATA_HOME:-$HOME/.local/share}/pki/nssdb"
  if [[ "$legacy_database" != "$HOME/.pki/nssdb" && -f "$legacy_database/cert9.db" ]]; then
    databases+=("$legacy_database")
  fi
fi

((${#databases[@]} > 0)) || die 'no NSS databases selected'

declare -a desired_names=()
if ((${#desired_file[@]} > 0)); then
  mapfile -t desired_names < <(printf '%s\n' "${!desired_file[@]}" | sort)
fi

list_managed_certificates() {
  local database="$1"
  certutil -L -d "sql:$database" 2>/dev/null \
    | awk '
      $1 ~ /^dotfiles-local-ca-[[:xdigit:]]{64}$/ ||
      $1 ~ /^smartcard-[[:xdigit:]]{64}$/ {
        print $1
      }
    '
}

sync_database() {
  local database="$1"
  local nickname
  local additions=0 refreshes=0 removals=0
  local database_exists=false
  local -a current_names=()
  local -A current_set=()

  if [[ -f "$database/cert9.db" ]]; then
    database_exists=true
    mapfile -t current_names < <(list_managed_certificates "$database")
    for nickname in "${current_names[@]}"; do
      current_set["$nickname"]=1
    done
  elif $purge; then
    printf '%s: no NSS database; nothing to purge\n' "$database"
    return
  fi

  for nickname in "${desired_names[@]}"; do
    if [[ -v "current_set[$nickname]" ]]; then
      ((refreshes += 1))
    else
      ((additions += 1))
    fi
  done

  for nickname in "${current_names[@]}"; do
    if [[ ! -v "desired_file[$nickname]" ]]; then
      ((removals += 1))
    fi
  done

  printf '%s: add %d, refresh %d, remove %d\n' \
    "$database" "$additions" "$refreshes" "$removals"

  if $dry_run; then
    for nickname in "${desired_names[@]}"; do
      if [[ ! -v "current_set[$nickname]" ]]; then
        printf '  + %s (%s)\n' "$nickname" "${desired_subject[$nickname]}"
      fi
    done
    for nickname in "${current_names[@]}"; do
      if [[ ! -v "desired_file[$nickname]" ]]; then
        printf '  - %s\n' "$nickname"
      fi
    done
    return
  fi

  if ! $database_exists; then
    mkdir -p "$database"
    chmod 700 "$database"
    certutil -N --empty-password -d "sql:$database"
  fi

  # Install and verify the complete desired set before deleting stale entries.
  for nickname in "${desired_names[@]}"; do
    certutil -D -d "sql:$database" -n "$nickname" >/dev/null 2>&1 || true
    certutil -A -d "sql:$database" -n "$nickname" \
      -t "${desired_trust[$nickname]}" -i "${desired_file[$nickname]}"
    certutil -L -d "sql:$database" -n "$nickname" >/dev/null 2>&1 \
      || die "failed to verify $nickname in $database"
  done

  for nickname in "${current_names[@]}"; do
    if [[ ! -v "desired_file[$nickname]" ]]; then
      certutil -D -d "sql:$database" -n "$nickname"
    fi
  done

  if [[ "${BROWSER_PKI_SKIP_PKCS11:-0}" != 1 ]]; then
    [[ -f "${P11_KIT_PROXY_MODULE:-}" ]] \
      || die 'P11_KIT_PROXY_MODULE does not point to p11-kit-proxy.so'
    if modutil -dbdir "sql:$database" -list 2>/dev/null \
      | grep -Fq 'p11-kit-proxy'; then
      modutil -force -dbdir "sql:$database" -delete p11-kit-proxy >/dev/null
    fi
    modutil -force -dbdir "sql:$database" -add p11-kit-proxy \
      -libfile "$P11_KIT_PROXY_MODULE" >/dev/null
  fi
}

printf 'Validated %d local trust anchors, %d smartcard roots, and %d smartcard intermediates.\n' \
  "$local_anchor_count" "$smartcard_anchor_count" "$smartcard_intermediate_count"

for database in "${databases[@]}"; do
  [[ -n "$database" ]] || die 'an empty NSS database path was supplied'
  sync_database "$database"
done

if $dry_run; then
  printf 'Dry run complete; no NSS databases were changed.\n'
else
  printf 'Browser PKI synchronization complete.\n'
fi
