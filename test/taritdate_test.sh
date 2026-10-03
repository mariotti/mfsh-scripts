#! /bin/sh
#
# Plain POSIX sh tests for bin/taritdate.sh. No framework: each test
# function prints PASS/FAIL lines and bumps $fail; the script exits
# non-zero if anything failed, so CI picks it up.
#
# Usage: sh test/taritdate_test.sh   (run from the repo root)
#
# Every test_* function below is invoked indirectly, by name, via
# run()/with_tmpdir(); shellcheck can't see that from the call site,
# so it flags the functions themselves (SC2329) and, cascading from
# that, every statement inside them as unreachable (SC2317).
# shellcheck disable=SC2329,SC2317

set -u

scriptdir=$(dirname "$0")
TARITDATE=$(cd "$scriptdir/.." && pwd)/bin/taritdate.sh
today=$(date +%Y%m%d)

fail=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; fail=$((fail + 1)); }

# Run test function $1 inside a fresh temp directory, in a subshell
# so a stray cd (or the test itself) can't affect the rest of the
# suite. Returns the test's exit status.
with_tmpdir() {
  tmp=$(mktemp -d)
  (cd "$tmp" && "$1")
  status=$?
  rm -rf "$tmp"
  return "$status"
}

test_no_args() {
  out=$("$TARITDATE" 2>&1)
  status=$?
  [ "$status" -eq 1 ] || return 1
  case "$out" in
    *"please give a dir name."*) return 0 ;;
    *) return 1 ;;
  esac
}

test_two_args() {
  mkdir d
  out=$("$TARITDATE" d extra 2>&1)
  status=$?
  [ "$status" -eq 1 ] || return 1
  case "$out" in
    *"only accept ONE directory"*) return 0 ;;
    *) return 1 ;;
  esac
}

test_not_a_directory() {
  touch notadir
  out=$("$TARITDATE" notadir 2>&1)
  status=$?
  [ "$status" -eq 1 ] || return 1
  case "$out" in
    *"only tar a directory"*) return 0 ;;
    *) return 1 ;;
  esac
}

test_creates_expected_tarball() {
  mkdir -p mydir
  echo hello > mydir/file.txt
  "$TARITDATE" mydir >/dev/null 2>&1 || return 1
  tarname="mydir.${today}.tar.gz"
  [ -f "$tarname" ] || return 1
  tar -tzf "$tarname" | grep -qx "mydir/file.txt"
}

test_collision_adds_suffix() {
  mkdir -p mydir
  echo hello > mydir/file.txt
  "$TARITDATE" mydir >/dev/null 2>&1 || return 1
  "$TARITDATE" mydir >/dev/null 2>&1 || return 1
  [ -f "mydir.${today}.tar.gz" ] || return 1
  [ -f "mydir.${today}.1.tar.gz" ] || return 1
}

test_trailing_slash_same_name_as_without() {
  mkdir -p mydir
  echo hello > mydir/file.txt
  "$TARITDATE" mydir/ >/dev/null 2>&1 || return 1
  [ -f "mydir.${today}.tar.gz" ]
}

run() {
  name=$1
  if with_tmpdir "$name"; then pass "$name"; else fail "$name"; fi
}

run test_no_args
run test_two_args
run test_not_a_directory
run test_creates_expected_tarball
run test_collision_adds_suffix
run test_trailing_slash_same_name_as_without

echo
if [ "$fail" -eq 0 ]; then
  echo "All tests passed."
  exit 0
else
  echo "$fail test(s) failed."
  exit 1
fi
