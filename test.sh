#!/bin/bash

function compile() {
    echo "$1" | ./8cc > tmp.s
    if [ $? -ne 0 ]; then
        echo "Failed to compile $1"
        exit
    fi
    gcc -o tmp.out driver.c tmp.s
    if [ $? -ne 0 ]; then
        echo "GCC failed"
        exit
    fi
}

function test() {
    expected="$1"
    expr="$2"

    compile "$expr"
    result="`./tmp.out`"
    if [ "$result" != "$expected" ]; then
        echo "Test failed: $expected expected but got $result"
        exit
    fi
}

function testfail() {
    expr="$1"
    echo $expr | ./8cc > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Should fail to compile, but secceeded: $expr"
        exit
    fi
}
make -s 8cc

echo 'test1: ' && test 0 0
echo 'test2: ' && test abc '"abc"'
echo 'test3: ' && test 3 '1+2'
echo 'test4: ' && test 3 '1 + 2'
echo 'test5: ' && test 10 '1+2+3+4'

echo 'test6: ' && testfail '"abc'
echo 'test7: ' && testfail '0abc'
echo 'test8: ' && testfail '1+'

echo "All tests passed"
