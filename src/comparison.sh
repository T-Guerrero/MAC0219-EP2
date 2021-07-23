#! /bin/bash

set -o xtrace

make
MEASUREMENTS=15
THREADS=4
PROCS=1

MPI_FLAG=0

NAMES=('mandelbrot_seq' 'mandelbrot_pth' 'mandelbrot_omp' 'mandelbrot_mpi' 'mandelbrot_mpi_pth' 'mandelbrot_mpi_omp')
mkdir -p ../measurements
echo "tipo,processos,threads,tempo" > ../measurements/comparison.csv

for NAME in ${NAMES[@]}; do

    if [ $MPI_FLAG -eq 1 ] ; then
        for k in $(seq $MEASUREMENTS); do
            mpirun -np $PROCS $NAME $THREADS >> ../measurements/comparison.csv
        done
    elif
        for k in $(seq $MEASUREMENTS); do
            ./$NAME $THREADS >> ../measurements/comparison.csv
        done
    fi

    if [ $NAME == 'mandelbrot_omp' ] ; then
        MPI_FLAG=1
    fi
    rm -f output.ppm
done