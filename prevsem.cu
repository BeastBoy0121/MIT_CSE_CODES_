#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>
#include <math.h>

__global__ void exam(char* A, int N)
{
	int row = blockIdx.x * blockDim.x + threadIdx.x;
	int col = blockIdx.y * blockDim.y + threadIdx.y;

	if ((row == 0 || row == N - 1) || (col == 0 || col == N - 1))
	{
		A[row * N + col] = '!';
	}
	int i;
	int count = 0;
	for (i = 1; i <= row; i++)
	{
		if (row % i == 0)
			count++;
	}
	if (count == 2 && A[row * N + col]=='\0')
	{
		A[row * N + col] = '*';
	}
	else if (count != 2 && A[row * N + col] == '\0')
	{
		A[row * N + col] = '#';
	}
	else
	{
		char e = A[row * N + col];
		if(e=='a'|| e == 'e' || e == 'i' || e == 'o' || e == 'u')
		{
			A[row * N + col] = e - 32;
		}
		else if (e == 'A' || e == 'E' || e == 'I' || e == 'O' || e == 'U')
		{
			A[row * N + col] = e + 32;
		}
	}
	
}

int main()
{
	int N;
	printf("Enter N:");
	scanf("%d", &N);
	int i, j;
	char* A = (char*)malloc(N * N * sizeof(char));
	printf("Enter matrix\n");
	char* temp=(char*)malloc(N * sizeof(char));
	for (i = 0; i < N; i++)
	{
		temp[i] = '\0';
	}
	int k = 0;
	for (i = 0; i < N; i++)
	{
		scanf("%s", temp);
		for (j = 0; j < N; j++)
		{
			A[k++] = temp[j];
		}
	}
	
	/*for (i = 0; i < N; i++)
	{
		for (j = 0; j < N; j++)
		{
			printf("%c ",A[i*N+j]);
		}
		printf("\n");
	}*/
	char* d_A;
	cudaMalloc((void**)&d_A, N * N * sizeof(char));

	cudaMemcpy(d_A, A, N * N * sizeof(char), cudaMemcpyHostToDevice);

	dim3 g(2, 2, 1);
	dim3 b(ceil(N / 2), ceil(N / 2), 1);
	exam << <g, b >> > (d_A,N);
	cudaMemcpy(A,d_A, N * N * sizeof(char), cudaMemcpyDeviceToHost);
	printf("Result:\n");
	for (i = 0; i < N; i++)
	{
		for (j = 0; j < N; j++)
		{
			printf("%c ",A[i*N+j]);
		}
		printf("\n");
	}

}