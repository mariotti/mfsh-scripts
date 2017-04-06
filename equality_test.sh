#!/bin/sh
# See: http://stackoverflow.com/questions/20449707/using-travis-ci-for-testing-on-unix-shell-scripts

testEquality() {
	assertEquals 1 1
}

. ./others/shunit2/source/2.1/src/shunit2

