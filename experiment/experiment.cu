// Simple CUDA example by Ingemar Ragnemalm 2009. Simplest possible?
// Assigns every element in an array with its index.

// nvcc simple.cu -L /usr/local/cuda/lib -lcudart -o simple

#include <stdio.h>
#include <stdlib.h>     /* srand, rand */
//https://cs.calvin.edu/courses/cs/374/CUDA/CUDA-Thread-Indexing-Cheatsheet.pdf
__global__ 
void experiment() 
{
	printf("blockIdx.x %i\n",blockIdx.x);
 	printf("blockIdx.y %i\n",blockIdx.y);
	printf("blockIdx.z %i\n",blockIdx.z);
	printf("\n");

	printf("blockDim.x %i\n",blockDim.x);
	printf("blockDim.y %i\n",blockDim.y);
	printf("blockDim.z %i\n",blockDim.z);
	printf("\n");

	printf("threadIdx.x %i\n",threadIdx.x);
	printf("threadIdx.y %i\n",threadIdx.y);
	printf("threadIdx.z %i\n",threadIdx.z);
	printf("\n");

	printf("gridDim.x %i\n",gridDim.x);
	printf("gridDim.y %i\n",gridDim.y);
	printf("gridDim.z %i\n",gridDim.z);
	printf("\n");



}

int main()
{	
	dim3 dimBlock( 1 ,1 ,2 );
	dim3 dimGrid( 1, 1, 1 );
	experiment<<<dimGrid, dimBlock>>>();
	cudaDeviceSynchronize();
	return EXIT_SUCCESS;
}
