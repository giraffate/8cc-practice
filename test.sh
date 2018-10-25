#!/bin/bash

function compile {
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

function assertequal {
    if [ "$1" != "$2" ]; then
        echo "Test failed: $2 expected but got $1"
        exit
    fi
}

function testast {
    result="$(echo "$2" | ./8cc -a)"
    if [ $? -ne 0 ]; then
        echo "Failed to compile $1"
        exit
    fi
    assertequal "$result" "$1"
}

function test {
    compile "$2"
    assertequal "$(./tmp.out)" "$1"
}

function testfail {
    expr="$1"
    echo $expr | ./8cc > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Should fail to compile, but secceeded: $expr"
        exit
    fi
}
make -s 8cc

echo 'test1: ' && testast '1' '1'
echo 'test2: ' && testast '(+ (- (+ 1 2) 3) 4)' '1+2-3+4'
echo 'test3: ' && testast '(+ (+ 1 (* 2 3)) 4)' '1+2*3+4'
echo 'test4: ' && testast '(+ (* 1 2) (* 3 4))' '1*2+3*4'
echo 'test5: ' && testast '(+ (/ 4 2) (/ 6 3))' '4/2+6/3'
echo 'test6: ' && testast '(/ (/ 24 2) 4)' '24/2/4'

echo 'test7: ' && test 0 0
echo 'test8: ' && test abc '"abc"'
echo 'test9: ' && test 3 '1+2'
echo 'test10: ' && test 3 '1 + 2'
echo 'test11: ' && test 10 '1+2+3+4'
echo 'test12: ' && test 11 '1+2*3+4'
echo 'test13: ' && test 14 '1*2+3*4'
echo 'test14: ' && test 4 '4/2+6/3'
echo 'test15: ' && test 3 '24/2/4'

echo 'test16: ' && testfail '"abc'
echo 'test17: ' && testfail '0abc'
echo 'test18: ' && testfail '1+'
echo 'test19: ' && testfail '1+"abc"'

echo "All tests passed"
