#! /bin/bash

set -o xtrace

MEASUREMENTS=10

ITERATIONS_SIZE=10
ITERATIONS_THREADS=5

INITIAL_SIZE=16
SIZE=$INITIAL_SIZE

INITIAL_THREADS=1
THREADS=$INITIAL_THREADS

NAMES=('mandelbrot_seq' 'mandelbrot_pth' 'mandelbrot_omp')

make
mkdir -p ../measurements
echo "tipo,tamanho,threads,tempo,io,figura" > ../measurements/data.csv

for NAME in ${NAMES[@]}; do

    for ((j=0; j<=$ITERATIONS_THREADS; j++)); do

        for ((i=1; i<=$ITERATIONS_SIZE; i++)); do
            for k in $(seq $MEASUREMENTS); do
                { ./$NAME -2.5 1.5 -2.0 2.0 $SIZE $THREADS; echo ",full"; } >> ../measurements/data.csv
            done
            for k in $(seq $MEASUREMENTS); do
                { ./$NAME -0.8 -0.7 0.05 0.15 $SIZE $THREADS; echo ",seahorseValley"; } >> ../measurements/data.csv
            done
            for k in $(seq $MEASUREMENTS); do
                { ./$NAME 0.175 0.375 -0.1 0.1 $SIZE $THREADS; echo ",elephantValley"; } >> ../measurements/data.csv
            done
            for k in $(seq $MEASUREMENTS); do
                { ./$NAME -0.188 -0.012 0.554 0.754 $SIZE $THREADS; echo ",tripleSpiralValley"; } >> ../measurements/data.csv
            done
            SIZE=$(($SIZE * 2))
            rm -f output.ppm
        done

        THREADS=$(($THREADS * 2))
        SIZE=$INITIAL_SIZE

        if [ $NAME == 'mandelbrot_seq' ] ; then
            break;
        fi
    done

    THREADS=$INITIAL_THREADS
done
