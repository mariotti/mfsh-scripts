#! /bin/sh
#
# Plain POSIX sh tests for bin/gplot.sh. No framework, no deps.
#
# The "happy path" tests stub out gnuplot (on $PATH, ahead of the
# real one) with a fake that just copies the generated plot script
# somewhere we can inspect, instead of actually launching gnuplot -
# the real plot file ends with `pause -1`, which blocks waiting for
# Enter on a terminal and would hang CI forever.
#
# Usage: sh test/gplot_test.sh   (run from the repo root)
#
# Every test_* function below is invoked indirectly, by name, via
# run()/with_tmpdir(); shellcheck can't see that from the call site,
# so it flags the functions themselves (SC2329) and, cascading from
# that, every statement inside them as unreachable (SC2317).
# shellcheck disable=SC2329,SC2317

set -u

scriptdir=$(dirname "$0")
repo_root=$(cd "$scriptdir/.." && pwd)
GPLOT=$repo_root/bin/gplot.sh

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

# Put a fake gnuplot on PATH (in the current, already-tmp, directory)
# that records the plot script it was given instead of running it.
install_fake_gnuplot() {
  mkdir fakebin
  cat << 'EOF' > fakebin/gnuplot
#! /bin/sh
cp "$1" "$FAKE_GNUPLOT_CAPTURE"
EOF
  chmod +x fakebin/gnuplot
  PATH="$PWD/fakebin:$PATH"
  export PATH
  FAKE_GNUPLOT_CAPTURE=$PWD/capture.plot
  export FAKE_GNUPLOT_CAPTURE
}

test_no_args() {
  out=$("$GPLOT" 2>&1)
  status=$?
  [ "$status" -eq 0 ] || return 1
  case "$out" in
    *"give a file name"*) return 0 ;;
    *) return 1 ;;
  esac
}

test_help() {
  out=$("$GPLOT" help 2>&1)
  status=$?
  [ "$status" -eq 0 ] || return 1
  case "$out" in
    *"Usage:"*"[numcols]"*) return 0 ;;
    *) return 1 ;;
  esac
}

test_non_numeric_numcols_rejected() {
  touch data.txt
  out=$("$GPLOT" data.txt abc 2>&1)
  status=$?
  [ "$status" -eq 1 ] || return 1
  case "$out" in
    *"numcols must be an integer"*) return 0 ;;
    *) return 1 ;;
  esac
}

test_numcols_below_2_rejected() {
  # Would have spun forever in the original csh version; must now
  # fail fast instead.
  touch data.txt
  out=$("$GPLOT" data.txt 1 2>&1)
  status=$?
  [ "$status" -eq 1 ] || return 1
  case "$out" in
    *"numcols must be an integer"*) return 0 ;;
    *) return 1 ;;
  esac
}

test_default_numcols_is_2() {
  install_fake_gnuplot
  touch data.txt
  out=$("$GPLOT" data.txt 2>&1)
  status=$?
  [ "$status" -eq 0 ] || return 1
  case "$out" in
    *"Plot cmd: plot 'data.txt' using 1:2"*) ;;
    *) return 1 ;;
  esac
  grep -qx "plot 'data.txt' using 1:2" "$FAKE_GNUPLOT_CAPTURE"
}

test_numcols_3_builds_two_extra_columns() {
  install_fake_gnuplot
  touch data.txt
  out=$("$GPLOT" data.txt 3 2>&1)
  status=$?
  [ "$status" -eq 0 ] || return 1
  expected="plot 'data.txt' using 1:2, 'data.txt' using 1:3"
  case "$out" in
    *"Plot cmd: $expected"*) ;;
    *) return 1 ;;
  esac
  grep -qx "$expected" "$FAKE_GNUPLOT_CAPTURE"
}

test_capture_file_has_expected_gnuplot_script() {
  install_fake_gnuplot
  touch data.txt
  "$GPLOT" data.txt 2 >/dev/null 2>&1 || return 1
  grep -qx "set style data linespoints" "$FAKE_GNUPLOT_CAPTURE" || return 1
  grep -q "^pause -1" "$FAKE_GNUPLOT_CAPTURE"
}

run() {
  name=$1
  if with_tmpdir "$name"; then pass "$name"; else fail "$name"; fi
}

run test_no_args
run test_help
run test_non_numeric_numcols_rejected
run test_numcols_below_2_rejected
run test_default_numcols_is_2
run test_numcols_3_builds_two_extra_columns
run test_capture_file_has_expected_gnuplot_script

echo
if [ "$fail" -eq 0 ]; then
  echo "All tests passed."
  exit 0
else
  echo "$fail test(s) failed."
  exit 1
fi
