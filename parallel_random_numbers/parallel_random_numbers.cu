//https://cs.calvin.edu/courses/cs/374/CUDA/CUDA-Thread-Indexing-Cheatsheet.pdf

// nvcc simple.cu -L /usr/local/cuda/lib -lcudart -o simple

#include <stdio.h>
#include <stdlib.h>     /* srand, rand */
#define N_THREADS (1<<10)
#define SIZE (int)(N_THREADS*sizeof(int))
#define N_COLOR 4

__global__ 
void random(int *seeds_gpu,int *randoms_gpu) 
{
	int result = seeds_gpu[threadIdx.x];
    result ^= result << 13;
    result ^= result >> 17;
    result ^= result << 5;
	randoms_gpu[threadIdx.x]=(result % N_COLOR+N_COLOR)%N_COLOR; //https://stackoverflow.com/questions/14997165/fastest-way-to-get-a-positive-modulo-in-c-c

}

int main()
{	
	printf("Number of threads %i\n",N_THREADS);
	int seeds[N_THREADS];
	int randoms[N_THREADS];

	for(int i = 0; i<N_THREADS;++i){
		seeds[i]=rand();
	}
	
	int *seeds_gpu;
	int *randoms_gpu;
	cudaMalloc( (void**)&seeds_gpu, SIZE );
	cudaMalloc( (void**)&randoms_gpu, SIZE );
	cudaMemcpy(seeds_gpu, seeds, SIZE, cudaMemcpyHostToDevice);


	dim3 dimBlock( N_THREADS ,1 , 1);
	dim3 dimGrid( 1, 1, 1 );
	random<<<dimGrid, dimBlock>>>(seeds_gpu,randoms_gpu);
	cudaDeviceSynchronize();

	cudaMemcpy( randoms, randoms_gpu, SIZE, cudaMemcpyDeviceToHost ); 

	cudaFree( randoms_gpu );
	cudaFree( seeds_gpu );

	for (int i = 0; i < N_THREADS; i++){
		printf("generated random number : %i\n",randoms[i]);
	}
	return EXIT_SUCCESS;
}
