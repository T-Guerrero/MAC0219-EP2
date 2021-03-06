#define _POSIX_C_SOURCE 199309L

#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define HOST 0

int id_mpi;
int size_mpi;
int chunk_mpi;

double c_x_min;
double c_x_max;
double c_y_min;
double c_y_max;

double pixel_width;
double pixel_height;

int iteration_max = 200;

int image_size;
unsigned char *image_buffer;

int i_x_max;
int i_y_max;
int image_buffer_size;

int gradient_size = 16;
int colors[17][3] = {
                        {66, 30, 15},
                        {25, 7, 26},
                        {9, 1, 47},
                        {4, 4, 73},
                        {0, 7, 100},
                        {12, 44, 138},
                        {24, 82, 177},
                        {57, 125, 209},
                        {134, 181, 229},
                        {211, 236, 248},
                        {241, 233, 191},
                        {248, 201, 95},
                        {255, 170, 0},
                        {204, 128, 0},
                        {153, 87, 0},
                        {106, 52, 3},
                        {16, 16, 16},
                    };

static double rtclock() {
  struct timespec t;
  clock_gettime(CLOCK_REALTIME, &t);
  return t.tv_sec + t.tv_nsec * 1e-9;
}

void allocate_image_buffer(){
    if (id_mpi == HOST)
        image_buffer = (unsigned char *) malloc(sizeof(unsigned char) * image_buffer_size);
    else
        image_buffer = (unsigned char *) malloc(sizeof(unsigned char) * (chunk_mpi * i_x_max));
};

void free_image_buffer() {
    free(image_buffer);
}

void init(int argc, char *argv[]){
    c_x_min = -0.188;
    c_x_max = -0.012;
    c_y_min = 0.554;
    c_y_max = 0.754;
    image_size = 4096;

    i_x_max           = image_size;
    i_y_max           = image_size;
    image_buffer_size = image_size * image_size;

    pixel_width       = (c_x_max - c_x_min) / i_x_max;
    pixel_height      = (c_y_max - c_y_min) / i_y_max;
};

void set_rgb_from_buffer(FILE *file, int i){
    int color;
    int iteration = image_buffer[i];
    unsigned char rgb[3];
    
    if(iteration == iteration_max){
        rgb[0] = colors[gradient_size][0];
        rgb[1] = colors[gradient_size][1];
        rgb[2] = colors[gradient_size][2];
    }
    else{
        color = iteration % gradient_size;

        rgb[0] = colors[color][0];
        rgb[1] = colors[color][1];
        rgb[2] = colors[color][2];
    };
    fwrite(rgb, 1 , 3, file);
};

void write_to_file(){
    FILE * file;
    char * filename               = "output.ppm";
    char * comment                = "# ";

    int max_color_component_value = 255;

    file = fopen(filename,"wb");

    fprintf(file, "P6\n %s\n %d\n %d\n %d\n", comment,
            i_x_max, i_y_max, max_color_component_value);

    for(int i = 0; i < image_buffer_size; i++){
        set_rgb_from_buffer(file, i);
    };

    fclose(file);
};

void compute_mandelbrot(int current){
    double z_x;
    double z_y;
    double z_x_squared;
    double z_y_squared;
    double escape_radius_squared = 4;

    int iteration;
    int i_x;

    double c_x;
    double c_y;

    for (int i = 0, i_y = current; i_y < current + chunk_mpi; i_y++, i++) {
        c_y = c_y_min + i_y * pixel_height;

        if(fabs(c_y) < pixel_height / 2){
            c_y = 0.0;
        };

        for(i_x = 0; i_x < i_x_max; i_x++){
            c_x         = c_x_min + i_x * pixel_width;

            z_x         = 0.0;
            z_y         = 0.0;

            z_x_squared = 0.0;
            z_y_squared = 0.0;

            for(iteration = 0;
                iteration < iteration_max && ((z_x_squared + z_y_squared) < escape_radius_squared);
                iteration++){
                z_y         = 2 * z_x * z_y + c_y;
                z_x         = z_x_squared - z_y_squared + c_x;

                z_x_squared = z_x * z_x;
                z_y_squared = z_y * z_y;
            }
            image_buffer[(i_x_max * i) + i_x] = iteration;
        }
    }
}

void mpi_managment(){
    int i_y;
    i_y = chunk_mpi*id_mpi;
    compute_mandelbrot(i_y);
    MPI_Gather(image_buffer, chunk_mpi*i_x_max, MPI_UNSIGNED_CHAR,
             image_buffer, chunk_mpi*i_x_max, MPI_UNSIGNED_CHAR, HOST, MPI_COMM_WORLD);
    MPI_Finalize();
}

int main(int argc, char *argv[]){
    init(argc, argv);
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &id_mpi);
    MPI_Comm_size(MPI_COMM_WORLD, &size_mpi);
    chunk_mpi = i_y_max/(size_mpi);

    allocate_image_buffer();

    double a = rtclock();
    mpi_managment();
    double b = rtclock();

    if (id_mpi == HOST)
        write_to_file();

    free_image_buffer();
    
    if (id_mpi == HOST)
        printf("mpi,%d,1,%lf\n", size_mpi, 1e3*(b-a));
    return 0;
};