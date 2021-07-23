#! /bin/bash

set -o xtrace

MEASUREMENTS=15

ITERATIONS_PROCS=5
ITERATIONS_THREADS=6

#1:*2:16
INITIAL_PROCS=1
PROCS=$INITIAL_PROCS

#1:*2:32
INITIAL_THREADS=1
THREADS=$INITIAL_THREADS

NAMES=('mandelbrot_mpi' 'mandelbrot_mpi_pth' 'mandelbrot_mpi_omp')

make
mkdir -p ../measurements
echo "tipo,processos,threads,tempo" > ../measurements/data.csv

for NAME in ${NAMES[@]}; do

    for ((j=0; j<$ITERATIONS_PROCS; j++)); do

        for ((i=0; i<$ITERATIONS_THREADS; i++)); do
            for k in $(seq $MEASUREMENTS); do
                { mpirun -np $PROCS $NAME $THREADS; } >> ../measurements/data.csv
            done

            THREADS=$(($THREADS * 2))
            rm -f output.ppm

            if [ $NAME == 'mandelbrot_mpi' ] ; then
                break;
            fi
        done
        THREADS=$INITIAL_THREADS
        PROCS=$(($PROCS * 2))
    done
    PROCS=$INITIAL_PROCS
done
