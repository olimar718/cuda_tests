//https://cs.calvin.edu/courses/cs/374/CUDA/CUDA-Thread-Indexing-Cheatsheet.pdf

// nvcc simple.cu -L /usr/local/cuda/lib -lcudart -o simple

#include <stdio.h>
#include <stdlib.h>     /* srand, rand */
#include <curand.h>
#include <curand_kernel.h>
#define N_THREADS (1<<10)
#define SIZE (int)(N_THREADS*sizeof(int))
#define N_COLOR 4

void histogram( int* h_nums)
{
    int hist[N_COLOR + 1]; // from 0 to N_COLOR, so (N_COLOR + 1) elements needed
    for (int i = 0; i < N_COLOR + 1; i++)
        hist[i] = 0;
    for (int i = 0; i < N_THREADS; i++)
        hist[h_nums[i]]++;
    for (int i = 0; i < N_COLOR + 1; i++)
        printf("%2d : %6d\n", i, hist[i]);
}

__global__ void init(unsigned int seed, curandState_t* states)
{
    unsigned int id = threadIdx.x;
    curand_init(seed, /* the seed can be the same for each thread, here we pass the time from CPU */
                id,   /* the sequence number should be different for each core */
                0,    /* the offset is how much extra we advance in the sequence for each call, can be 0 */
                &states[id]);
}

__global__ 
void random(int *randoms_gpu, curandState_t *  states) 
{
	unsigned int id=threadIdx.x;
	randoms_gpu[id]=curand_uniform(&states[id]) * (N_COLOR) ;
	//ternary set     b=( a == 5 ) ? c : b; to avoid branches
}

int main()
{	
	printf("Number of threads %i\n",N_THREADS);
	int randoms[N_THREADS];
	int seed=time(0);
	printf("seed : %i\n",seed);
	curandState_t* states;
    cudaMalloc((void**)&states, N_THREADS * sizeof(curandState_t));
	int *randoms_gpu;
	cudaMalloc( (void**)&randoms_gpu, SIZE );
	dim3 dimBlock( N_THREADS ,1 , 1);
	dim3 dimGrid( 1, 1, 1 );
    init<<<dimGrid, dimBlock >>>(time(0), states);
	random<<<dimGrid,dimBlock>>>(randoms_gpu,states);
	cudaDeviceSynchronize();
	cudaMemcpy( randoms, randoms_gpu, SIZE, cudaMemcpyDeviceToHost ); 

	cudaFree( randoms_gpu );
	cudaFree( states );

	
	histogram(randoms);
	return EXIT_SUCCESS;
}
