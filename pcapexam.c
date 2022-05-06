#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>

__global__ void strfunc(char *A,int* B,char* out)
{
	int idx = threadIdx.x;
	int si = 0;
	int i;
	for (i = 0; i < idx; i++)
	{
		si += B[i];
	}
	int k = 0;
	for (i = 0; i < B[idx]; i++)
	{
		out[si+i] = A[idx];
	}
}

int main()
{
	char A[2][4] = { {'p','C','a','P'},{'e','X','a','M'} };
	int B[2][4] = { {1,2,4,3},{2,4,3,2} };
	int len = 0;
	int i, j;
	for (i = 0; i < 2; i++)
	{
		for (j = 0; j < 4; j++)
		{
			len += B[i][j];
		}
	}
	char* d_A, * d_out;
	int* d_B;
	char* out = (char*)malloc(len * sizeof(char));
	cudaMalloc((void**)&d_A, 8 * sizeof(char));
	cudaMalloc((void**)&d_B, 8 * sizeof(int));
	cudaMalloc((void**)&d_out, len * sizeof(char));

	cudaMemcpy(d_A, A, 8 * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, 8 * sizeof(int), cudaMemcpyHostToDevice);

	dim3 g(1, 1, 1);
	dim3 b(8, 1, 1);
	strfunc << <g, b >> > (d_A, d_B, d_out);

	cudaMemcpy(out,d_out, len * sizeof(char), cudaMemcpyDeviceToHost);
	out[len] = '\0';
	printf("Out=%s\n", out);
}