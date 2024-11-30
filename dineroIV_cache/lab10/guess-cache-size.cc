#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

double get_time_usec() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec * 1e6 + (double)tv.tv_usec;
}

double measure_access_time(int* arr, long size, int iterations) {
    double start_time, end_time;
    long index = 0;
    volatile int dummy = 0;
    
    for (int i = 0; i < size; i += 97) {
        dummy += arr[i % size];
    }
    
    start_time = get_time_usec();
    
    for (int i = 0; i < iterations; i++) {
        index = (index + 97) % size;
        dummy += arr[index];
    }
    
    end_time = get_time_usec();
    
    return (end_time - start_time) / iterations;
}

void create_gnuplot_script(const char* data_file, const char* script_file, long cache_size) {
    FILE* fp = fopen(script_file, "w");
    fprintf(fp, "set terminal pngcairo enhanced size 1024,768\n");
    fprintf(fp, "set output 'cache_analysis.png'\n");
    fprintf(fp, "set title 'Memory Access Time vs Array Size'\n");
    fprintf(fp, "set xlabel 'Cache size'\n");
    fprintf(fp, "set ylabel 'Access Time (microseconds)'\n");
    fprintf(fp, "set logscale x 2\n");
    fprintf(fp, "set grid\n");
    fprintf(fp, "set key right bottom\n");
    
    fprintf(fp, "stats '%s' using 2 nooutput\n", data_file);
    fprintf(fp, "set arrow 1 from %ld,STATS_min to %ld,STATS_max nohead lc rgb 'red'\n", 
            cache_size/1024, cache_size/1024);
    
    fprintf(fp, "plot '%s' using ($1/1024):2 with linespoints title 'Access Time' pt 7 ps 0.5 lc rgb '#0060ad',\\\n", 
            data_file);
    fprintf(fp, "     NaN title sprintf('Detected Cache Size: %%d KB', %ld) lc rgb 'red'\n", 
            cache_size/1024);
    
    fclose(fp);
}

int main() {
    double prev_time = 0;
    double current_time;
    long possible_cache_size = 0;
    double max_time_jump = 0;
    
    int* arr = (int*)malloc(64*1024*1024 * sizeof(int));
    if (arr == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }
    
    srand(time(NULL));
    for (long i = 0; i < 64*1024*1024 / sizeof(int); i++) {
        arr[i] = rand();
    }
    
    FILE* data_fp = fopen("cache_data.tmp", "w");
    if (data_fp == NULL) {
        printf("Failed to create data file!\n");
        free(arr);
        return 1;
    }
    
    for (long size = 4*1024 / sizeof(int); 
         size <= 64*1024*1024 / sizeof(int); 
         size *= 2) {
        
        int iterations = 10000 / (size / (4*1024 / sizeof(int)));
        if (iterations < 100) iterations = 100;
        
        current_time = measure_access_time(arr, size, iterations);
        fprintf(data_fp, "%ld %.3f\n", size * sizeof(int), current_time);
        
        if (prev_time > 0) {
            double time_jump = current_time / prev_time;
            if (time_jump > max_time_jump) {
                max_time_jump = time_jump;
                possible_cache_size = size * sizeof(int);
            }
        }
        
        prev_time = current_time;
    }
    
    fclose(data_fp);
    
    create_gnuplot_script("cache_data.tmp", "plot_cache.gp", possible_cache_size);
    system("gnuplot plot_cache.gp");
    system("rm cache_data.tmp plot_cache.gp");
    free(arr);
    return 0;
}
