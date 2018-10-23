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

echo 'test3: ' && test 0 0
echo 'test4: ' && test abc '"abc"'
echo 'test5: ' && test 3 '1+2'
echo 'test6: ' && test 3 '1 + 2'
echo 'test7: ' && test 10 '1+2+3+4'
echo 'test8: ' && test 4 '1+2-3+4'

echo 'test9: ' && testfail '"abc'
echo 'test10: ' && testfail '0abc'
echo 'test11: ' && testfail '1+'
echo 'test12: ' && testfail '1+"abc"'

echo "All tests passed"
