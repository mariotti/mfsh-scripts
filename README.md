[![CI](https://github.com/mariotti/mfsh-scripts/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/mariotti/mfsh-scripts/actions/workflows/ci.yml)

# A collection of shell scripts

This is not a project, but more a collection of maybe
useful things I collected during the years.

Some are from my old blog.

# Programs

## bin/gplot.sh

Quick multi-column plotting with gnuplot. (Converted from the
original `gplot.csh`.)

Example (gnuplot normally opens a GUI window; this is what you get
with `GNUTERM=dumb`, e.g. over an ssh session with no display):

```
$ GNUTERM=dumb gplot.sh data.txt
Plot cmd: plot 'data.txt' using 1:2

  9 +---------------------------------------------------+
    |      +       +      +       +      +     **+ **** |
  8 |-+                    'data.txt' using 1:* ***A****|
    |                                        *          |
  7 |-+                           A*       **         +-|
    |                           **  ****  *             |
  6 |-+                        *        *A            +-|
    |                         *                         |
  5 |-+           *A*       **                        +-|
    |           **   ****  *                            |
  4 |-+       **         *A                           +-|
    |       **                                          |
  3 |-+   *A                                          +-|
    | **** +       +      +       +      +       +      |
  2 +---------------------------------------------------+
    1      2       3      4       5      6       7      8

Hit return to continue
```

## bin/taritdate.sh

Tars a directory into `<dir>.<YYYYMMDD>.tar.gz`, adding a numeric suffix
if that name is already taken.

Example:

```
$ taritdate.sh photos
$ ls -al photos.*.tar.gz
-rw-r--r--  1 mariotti  wheel  187 Oct  3 21:15 photos.20261003.tar.gz
```

## backmeup

Moved to its own project: [bmug2](https://github.com/mariotti/bmug2)
(continuation of the original [bmu](https://github.com/mariotti/bmu))

## Others

A section of random commands I need to keep handy, just in case.

- `others/jq/RECIPES.md` — jq recipes for walking/renaming/merging JSON.

# Tests

Plain POSIX-sh tests, no framework, no dependencies:

    sh test/taritdate_test.sh
    sh test/gplot_test.sh

`gplot_test.sh` stubs out `gnuplot` on `$PATH` instead of calling the
real one — the generated plot script ends with `pause -1`, which
blocks waiting for Enter on a terminal.

Also checked in CI: `shellcheck` on `bin/*.sh` and `test/*.sh`.

# License

MIT, see [LICENSE](LICENSE).
