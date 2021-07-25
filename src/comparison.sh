#! /bin/bash

set -o xtrace

make
MEASUREMENTS=15
MPI_SEQ_PROCS=16
MPI_THRD_PROCS=4
THREADS=8

MPI_FLAG=0

NAMES=('mandelbrot_seq' 'mandelbrot_pth' 'mandelbrot_omp' 'mandelbrot_mpi' 'mandelbrot_mpi_pth' 'mandelbrot_mpi_omp')
mkdir -p ../measurements
echo "tipo,processos,threads,tempo" > ../measurements/comparison.csv

for NAME in ${NAMES[@]}; do

    if [ $NAME == 'mandelbrot_mpi' ] ; then
        for k in $(seq $MEASUREMENTS); do
            mpirun -np $MPI_SEQ_PROCS $NAME >> ../measurements/comparison.csv
        done
        MPI_FLAG=1

    elif [ $MPI_FLAG -eq 1 ] ; then
        for k in $(seq $MEASUREMENTS); do
            mpirun -np $MPI_THRD_PROCS $NAME $THREADS >> ../measurements/comparison.csv
        done

    else
        for k in $(seq $MEASUREMENTS); do
            ./$NAME $THREADS >> ../measurements/comparison.csv
        done
    fi

    rm -f output.ppm
done