OUTPUT=mandelbrot

IMAGE=.ppm

CC=gcc
CC_OPT=-std=c11
MCC=mpicc

CC_OMP=-fopenmp
CC_PTH=-pthread

.PHONY: all
all: $(OUTPUT)_omp $(OUTPUT)_pth $(OUTPUT)_seq $(OUTPUT)_mpi_omp $(OUTPUT)_mpi_pth $(OUTPUT)_mpi

$(OUTPUT)_omp: $(OUTPUT)_omp.c
	$(CC) -o $(OUTPUT)_omp $(CC_OPT) $(CC_OMP) $(OUTPUT)_omp.c

$(OUTPUT)_pth: $(OUTPUT)_pth.c
	$(CC) -o $(OUTPUT)_pth $(CC_OPT) $(CC_PTH) $(OUTPUT)_pth.c

$(OUTPUT)_seq: $(OUTPUT)_seq.c
	$(CC) -o $(OUTPUT)_seq $(CC_OPT) $(OUTPUT)_seq.c

$(OUTPUT)_mpi_omp: $(OUTPUT)_mpi_omp.c
	$(MCC) -o $(OUTPUT)_mpi_omp $(CC_OPT) $(CC_OMP) $(OUTPUT)_mpi_omp.c

$(OUTPUT)_mpi_pth: $(OUTPUT)_mpi_pth.c
	$(MCC) -o $(OUTPUT)_mpi_pth $(CC_OPT) $(CC_PTH) $(OUTPUT)_mpi_pth.c

$(OUTPUT)_mpi: $(OUTPUT)_mpi.c
	$(MCC) -o $(OUTPUT)_mpi $(CC_OPT) $(OUTPUT)_mpi.c

.PHONY: clean
clean:
	rm -f $(OUTPUT)_omp $(OUTPUT)_pth $(OUTPUT)_seq $(OUTPUT)_mpi_omp $(OUTPUT)_mpi_pth $(OUTPUT)_mpi *$(IMAGE)
