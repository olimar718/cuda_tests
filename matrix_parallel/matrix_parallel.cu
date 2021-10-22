// Simple CUDA example by Ingemar Ragnemalm 2009. Simplest possible?
// Assigns every element in an array with its index.

// nvcc simple.cu -L /usr/local/cuda/lib -lcudart -o simple

#include <stdio.h>
#include <math.h>

const int N = 16; 
const int blocksize = 16;

__global__
void add_matrix(float *a, float *b, float *c)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x + blockIdx.y * blockDim.y * N;
    c[idx] = a[idx] + b[idx];
}

int main()
{
	const int N = 16;
    const int size = N*sizeof(float)*N;
    float *a_gpu;
    float *b_gpu;
    float *c_gpu;

	float *a = new float[N*N];
	float *b= new float[N*N];
    float *c= new float[N*N];

    for (int i = 0; i < N; i++){
		for (int j = 0; j < N; j++)
		{
			a[i+j*N] = 10 + i;
			b[i+j*N] = float(j) / N;
		}
	}
	cudaMalloc( (void**)&a_gpu, size );
    cudaMalloc( (void**)&b_gpu, size );
    cudaMalloc( (void**)&c_gpu, size );
	dim3 dimBlock( blocksize, blocksize );
	dim3 dimGrid( 1, 1 );

	cudaMemcpy(a_gpu, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(b_gpu, b, size, cudaMemcpyHostToDevice);
    cudaMemcpy(c_gpu, c, size, cudaMemcpyHostToDevice);

    add_matrix<<<dimBlock, dimGrid>>>(a_gpu, b_gpu, c_gpu);
	cudaDeviceSynchronize();
	cudaMemcpy( c, c_gpu, size, cudaMemcpyDeviceToHost ); 
	cudaFree( a_gpu );
    cudaFree( b_gpu );
    cudaFree( c_gpu );

	
	for (int i = 0; i < N; i++){
        for(int j = 0; j < N; j++){
		    printf("%f ", c[i+j*N]);
        }
        printf("\n");
	}
	printf("\n");
	delete[] c;
    delete[] a;
    delete[] b;

	printf("done\n");
	return EXIT_SUCCESS;
}
