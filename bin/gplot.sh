#! /bin/sh
#
# F.Mariotti: gplot.sh (converted from the original gplot.csh)
#
# Quick multi-column plotting with gnuplot: plots column 1 against
# columns 2..numcols of a data file.
#
if [ -z "$1" ]; then
  echo "give a file name..."
  exit 0
fi
if [ "$1" = "help" ]; then
  echo "Usage: $0 <file> [numcols]"
  echo ""
  exit 0
fi
#
if [ -z "$2" ]; then
  numcols=2
else
  numcols=$2
fi
#
# numcols must be a plain integer >= 2 (we always plot at least
# column 2 against column 1); anything else would either make the
# "while cnum != numcols" loop below never terminate (numcols < 2,
# since cnum only ever increases) or blow up on the arithmetic test
# (numcols not a number). The original csh version had the same bug:
# it just crashed on non-numeric input and spun forever on numcols
# < 2, so fail with a clear message instead.
case "$numcols" in
  ''|*[!0-9]*)
    echo "numcols must be an integer >= 2" >&2
    exit 1
    ;;
esac
if [ "$numcols" -lt 2 ]; then
  echo "numcols must be an integer >= 2" >&2
  exit 1
fi
#
cnum=2
pltcmd="plot '$1' using 1:2"
while [ "$cnum" -ne "$numcols" ]; do
  cnum=$((cnum + 1))
  pltcmd="${pltcmd}, '$1' using 1:${cnum}"
done
#
echo "Plot cmd: $pltcmd"
#
# Use a proper tmp file instead of x.plot.$$ in the current
# directory (that's where the original csh version put it).
plotfile=$(mktemp "${TMPDIR:-/tmp}/gplot.XXXXXX") || exit 1
cat << EOF > "$plotfile"
set style data linespoints
$pltcmd
pause -1 "Hit return to continue"
EOF
#
gnuplot "$plotfile"
#
rm -f "$plotfile"
#
