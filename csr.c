#include <stdio.h>
#include<cuda.h>
#include<string.h>


__global__ void csr(int *data,int *col_index,int* row_ptr,int* x,int* y)
{
	int row = blockIdx.x * blockDim.x + threadIdx.x;
	int row_start = row_ptr[row];
	int row_end = row_ptr[row + 1];
	int k;
	int dot = 0;
	for (k = row_start; k < row_end; k++)
	{
		dot += data[k] * x[col_index[k]];
	}
	y[row] = dot;
}

int main()
{
	int a[4][4] = { {3,0,1,0},{0,0,0,0},{0,2,4,1},{1,0,0,1} };
	int* row_ptr, * col_index, * data, * y;
	int nzcount = 0;
	int i, j;
	row_ptr = (int*)malloc(5 * sizeof(int));
	row_ptr[0] = 0;
	for (i = 0; i < 4; i++)
	{
		for (j = 0; j < 4; j++)
		{
			if (a[i][j] != 0)
			{
				nzcount++;
			}
		}
		row_ptr[i + 1] = nzcount;
	}
	col_index = (int*)malloc(nzcount * sizeof(int));
	data = (int*)malloc(nzcount * sizeof(int));
	y = (int*)malloc(4 * sizeof(int));
	int k = 0;
	for (i = 0; i < 4; i++)
	{
		for (j = 0; j < 4; j++)
		{
			if (a[i][j] != 0)
			{
				data[k] = a[i][j];
				col_index[k++] = j;
			}
		}
	}
	
	for (i = 0; i < nzcount; i++)
	{
		printf("%d\t", data[i]);
	}
	printf("\n");
	for (i = 0; i < nzcount; i++)
	{
		printf("%d\t", col_index[i]);
	}
	printf("\n");
	for (i = 0; i < 5; i++)
	{
		printf("%d\t", row_ptr[i]);
	}
	int* d_data, * d_col_index, * d_row_ptr, * d_x, *d_y;
	int x[4] = { 1,2,3,4 };
	
	cudaMalloc((void**)&d_data, nzcount * sizeof(int));
	cudaMalloc((void**)&d_col_index, nzcount * sizeof(int));
	cudaMalloc((void**)&d_row_ptr, 5 * sizeof(int));
	cudaMalloc((void**)&d_y, 4 * sizeof(int));
	cudaMalloc((void**)&d_x, 4 * sizeof(int));

	cudaMemcpy(d_data, data, nzcount * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_col_index, col_index, nzcount * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_row_ptr, row_ptr, 5 * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_x, x, 4 * sizeof(int), cudaMemcpyHostToDevice);
	
	dim3 g(1, 1, 1);
	dim3 b(4, 1, 1);
	csr << <g, b >> > (d_data, d_col_index, d_row_ptr, d_x,d_y);
	cudaMemcpy(y, d_y, 4 * sizeof(int), cudaMemcpyDeviceToHost);
	printf("Y:\n");
	for (i = 0; i < 4; i++)
	{
		printf("%d\t", y[i]);
	}

}