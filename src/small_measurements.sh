#! /bin/bash

set -o xtrace

make
NAMES=('mandelbrot_seq' 'mandelbrot_pth' 'mandelbrot_omp')
MEASUREMENTS=10
SIZE=4096
THREADS=4

mkdir -p ../measurements

for NAME in ${NAMES[@]}; do
    mkdir -p ../measurements/$NAME
    perf stat -r $MEASUREMENTS ./$NAME -2.5 1.5 -2.0 2.0 $SIZE $THREADS >> ../measurements/$NAME/full.log 2>&1
    perf stat -r $MEASUREMENTS ./$NAME -0.8 -0.7 0.05 0.15 $SIZE $THREADS >> ../measurements/$NAME/seahorse.log 2>&1
    perf stat -r $MEASUREMENTS ./$NAME 0.175 0.375 -0.1 0.1 $SIZE $THREADS >> ../measurements/$NAME/elephant.log 2>&1
    perf stat -r $MEASUREMENTS ./$NAME -0.188 -0.012 0.554 0.754 $SIZE $THREADS >> ../measurements/$NAME/triple_spiral.log 2>&1

    rm -f output.ppm
done