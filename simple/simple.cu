// Simple CUDA example by Ingemar Ragnemalm 2009. Simplest possible?
// Assigns every element in an array with its index.

// nvcc simple.cu -L /usr/local/cuda/lib -lcudart -o simple

#include <stdio.h>
#include <math.h>

const int N = 16; 
const int blocksize = 16;

__global__ 
void simple(float *cd) 
{
	cd[threadIdx.x] = pow(cd[threadIdx.x],2);
	printf("bonjour\n");
	cd[threadIdx.x] = sqrt(cd[threadIdx.x]);
}

int main()
{
	float *c = new float[N];
	float *cd;
	const int size = N*sizeof(float);

	for(int i=0; i<N; i++){
		c[i] = i*2;
	}	
	
	cudaMalloc( (void**)&cd, size );
	dim3 dimBlock( blocksize, 1 );
	dim3 dimGrid( 1, 1 );

	cudaMemcpy(cd, c, size, cudaMemcpyHostToDevice);

	simple<<<dimGrid, dimBlock>>>(cd);
	cudaDeviceSynchronize();
	cudaMemcpy( c, cd, size, cudaMemcpyDeviceToHost ); 
	cudaFree( cd );
	
	for (int i = 0; i < N; i++){
		printf("%f ", c[i]);
	}
	printf("\n");
	delete[] c;
	printf("done\n");
	return EXIT_SUCCESS;
}
