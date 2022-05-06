#include<stdio.h>
#include<stdlib.h>
#include"cuda_runtime.h"
#include"device_launch_parameters.h"

__device__ int isfib(int num)
{
    int a = 1, b = 1, isfib = 0;
    while (num >= b)
    {
        if (num == b)
        {
            isfib = 1;
            break;
        }
        else
        {
            int temp = a + b;
            a = b;
            b = temp;
        }
    }
    if (isfib == 1)
        return 1;
    else
        return 0;
}
__device__ int octal(int num)
{
    int octal_num = 0, countval = 1;
    while (num != 0) {

        int remainder = num % 8;
        octal_num += remainder * countval;
        countval = countval * 10;
        num = num / 8;
    }
    return octal_num;
}
__global__ void fun(int* A, int* B, int M, int N, int* totalfibcount)
{
    int row = threadIdx.y + blockIdx.y * blockDim.y;
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    if (row == 0 || col == 0 || row == M - 1 || col == N - 1)
    {
        B[(row)*N + col] = octal(A[(row)*N + col]);
        if(isfib(A[(row)*N + col]))
        {
            int a = atomicAdd(totalfibcount, 1);
        }
    }
    else
    {
        int fibcount = 0;
        fibcount += isfib(A[(row)*N + (col - 1)]);
        fibcount += isfib(A[(row)*N + (col + 1)]);
        fibcount += isfib(A[(row - 1) * N + (col)]);
        fibcount += isfib(A[(row + 1) * N + (col)]);
        fibcount += isfib(A[(row - 1) * N + (col - 1)]);
        fibcount += isfib(A[(row + 1) * N + (col - 1)]);
        fibcount += isfib(A[(row - 1) * N + (col + 1)]);
        fibcount += isfib(A[(row + 1) * N + (col + 1)]);
        B[row * N + col] = fibcount;
        if(isfib(A[(row)*N + col]))
        {
            int a = atomicAdd(totalfibcount, 1);
        }
    }
}
int main()
{
    int M = 4, N = 4;
    int A[100], B[100];
    printf("Enter the matrix elements of A: ");
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
            scanf("%d", &A[i * N + j]);
    }
    printf("A:\n");
    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < N; j++)
            printf("%d\t", A[i * N + j]);
        printf("\n");
    }
    int totalfibcount = 0;
    int size = M * N * sizeof(int);
    int* d_A, * d_B, * d_totalfibcount;
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_totalfibcount, sizeof(int));
    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_totalfibcount, &totalfibcount, sizeof(int), cudaMemcpyHostToDevice);
    dim3 dimBlock(N, M, 1);
    dim3 dimGrid(1, 1, 1);
    fun <<< dimGrid, dimBlock >> > (d_A, d_B, M, N, d_totalfibcount);
    cudaMemcpy(B, d_B, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(&totalfibcount, d_totalfibcount, sizeof(int), cudaMemcpyDeviceToHost);
    printf("B:\n");
    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < N; j++)
            printf("%d\t", B[i * N + j]);
        printf("\n");
    }
    printf("Total Fibonacci count: %d\n", totalfibcount);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_totalfibcount);
}