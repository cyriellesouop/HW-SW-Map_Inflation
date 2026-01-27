/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include <xil_io.h>
#include "xil_types.h"
#include <stdlib.h>
#include <time.h>
#include <xstatus.h>
#include "../../platform/hw/sdt/drivers/simpleCpu_v1_0/src/simpleCpu.h"
#include "../../platform/hw/sdt/drivers/MyCpuMult_v1_0/src/MyCpuMult.h"
#include "xtmrctr.h"
#include "xgpio.h"

#define ROW 2
#define COL 2

#define TIMER_DEVICE_ID XPAR_AXI_TIMER_0_BASEADDR
#define TIMER_COUNTER_0 0

// GPIO MACRO
#define GPIO_ID XPAR_XGPIO_0_BASEADDR
#define GPIO_CHANNEL 1
#define GPIO_DIRECTION_MASK 0
#define GPIO_VALUE_TO_WRITE_ON 0b1111111111111111
#define GPIO_VALUE_TO_WRITE_OFF 0b0000000000000000

//typedef u64 XTime;

void genMatrix(u32* A)

{
    srand(time(NULL)); 
    for (int i = 0; i < (ROW * COL); i++) {
        A[i] = rand() % 10;
    }
}

void matMul(u32* A, u32* B, u32* C)
{
   // xil_printf("\nMULT:\n");

    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < COL; j++) {
            u32 sum = 0;
            for (int k = 0; k < COL; k++) {
                 sum = sum + A[i*COL+k] * B[k*COL+j];
            }
             C[i*COL+j] = sum;
           // xil_printf("%d, %d = %d\n", i,j,C[i*COL+j] );
        }
    }
}

void matMul_simpleCpu(u32* A, u32* B, u32* C)
{
   // xil_printf("\nMULT:\n");

    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < COL; j++) {
            u32 sum = 0;
            for (int k = 0; k < COL; k++) {
                u32 tmp = A[i*COL+k] * B[k*COL+j];
                
                SIMPLECPU_mWriteReg(XPAR_SIMPLECPU_0_BASEADDR, SIMPLECPU_S00_AXI_SLV_REG0_OFFSET,sum);
                SIMPLECPU_mWriteReg(XPAR_SIMPLECPU_0_BASEADDR, SIMPLECPU_S00_AXI_SLV_REG1_OFFSET, tmp);
                sum = SIMPLECPU_mReadReg(XPAR_SIMPLECPU_0_BASEADDR, SIMPLECPU_S00_AXI_SLV_REG3_OFFSET); 
            }
             C[i*COL+j] = sum;
           // xil_printf("%d, %d = %d\n", i,j,C[i*COL+j] );
        }
    }
}

void matMul_simpleCpu_add_Mult(u32* A, u32* B, u32* C)
{
   // xil_printf("\nMULT:\n");

    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < COL; j++) {
            u32 sum = 0;
            for (int k = 0; k < COL; k++) {
               // u32 tmp = A[i*COL+k] * B[k*COL+j];
               // u32 tmp = 0;
                MYCPUMULT_mWriteReg( XPAR_MYCPUMULT_0_BASEADDR, MYCPUMULT_S00_AXI_SLV_REG0_OFFSET, A[i*COL+k]);
                MYCPUMULT_mWriteReg( XPAR_MYCPUMULT_0_BASEADDR, MYCPUMULT_S00_AXI_SLV_REG1_OFFSET, B[k*COL+j]);

                //MYCPUMULT_mReadReg(BaseAddress, RegOffset)
                 u32  tmp =  MYCPUMULT_mReadReg (XPAR_MYCPUMULT_0_BASEADDR, MYCPUMULT_S00_AXI_SLV_REG3_OFFSET);

                SIMPLECPU_mWriteReg(XPAR_SIMPLECPU_0_BASEADDR, SIMPLECPU_S00_AXI_SLV_REG0_OFFSET,sum);
                SIMPLECPU_mWriteReg(XPAR_SIMPLECPU_0_BASEADDR, SIMPLECPU_S00_AXI_SLV_REG1_OFFSET, tmp);
                sum = SIMPLECPU_mReadReg(XPAR_SIMPLECPU_0_BASEADDR, SIMPLECPU_S00_AXI_SLV_REG3_OFFSET); 
            }
             C[i*COL+j] = sum;
           // xil_printf("%d, %d = %d\n", i,j,C[i*COL+j] );
        }
    }
}

void matMul_simpleCpu_Mult(u32* A, u32* B, u32* C)
{
   // xil_printf("\nMULT:\n");

    for (int i = 0; i < ROW; i++) {
        for (int j = 0; j < COL; j++) {
            u32 sum = 0;
            for (int k = 0; k < COL; k++) {
               // u32 tmp = A[i*COL+k] * B[k*COL+j];
                u32 tmp = 0;
                MYCPUMULT_mWriteReg( XPAR_MYCPUMULT_0_BASEADDR, MYCPUMULT_S00_AXI_SLV_REG0_OFFSET, A[i*COL+k]);
                MYCPUMULT_mWriteReg( XPAR_MYCPUMULT_0_BASEADDR, MYCPUMULT_S00_AXI_SLV_REG1_OFFSET, B[k*COL+j]);

                //MYCPUMULT_mReadReg(BaseAddress, RegOffset)
                tmp =  MYCPUMULT_mReadReg (XPAR_MYCPUMULT_0_BASEADDR, MYCPUMULT_S00_AXI_SLV_REG3_OFFSET);

                sum = sum + tmp;
            }
             C[i*COL+j] = sum;
           // xil_printf("%d, %d = %d\n", i,j,C[i*COL+j] );
        }
    }
}

u8 compareMatrices(u32* vec1, u32* vec2){
    for (int i = 0; i < ROW*COL; ++i) {
        if(vec1[i] != vec2[i])
            return 0;
    }
    return 1;

}

int main()
{
    init_platform();
   // xil_printf("Hi Aud\r\n");


    XGpio Gpio;

    // code section to write to my 2 LEDs through the AXI GPIO IP
    int Status = XGpio_Initialize(&Gpio , GPIO_ID);
    if(Status != XST_SUCCESS)
        xil_printf("1-%d\n", Status);
    XGpio_SetDataDirection(&Gpio, GPIO_CHANNEL, GPIO_DIRECTION_MASK);

    // while(1){
    //     XGpio_DiscreteWrite(&Gpio, GPIO_CHANNEL, GPIO_VALUE_TO_WRITE_ON);
    //     usleep(2000000); //waiting for 2 seconds
    //     XGpio_DiscreteWrite(&Gpio, GPIO_CHANNEL, GPIO_VALUE_TO_WRITE_OFF); 
    //     usleep(2000000); //waiting for 2 seconds
    // }

    u32* A = (u32*) malloc(ROW * COL * sizeof(u32));
    u32* B = (u32*) malloc(ROW * COL * sizeof(u32));
    u32* C = (u32*) malloc(ROW * COL * sizeof(u32));
    u32* D = (u32*) malloc(ROW * COL * sizeof(u32));
    u32* E = (u32*) malloc(ROW * COL * sizeof(u32));


    genMatrix(A);
    genMatrix(B); 
    XTmrCtr InstancePtr;
    //TIMER_DEVICE_ID
    //1. Initialiaze the AXI timer IP
    //&InstancePtr : instance of the pointer to the driver
    
     Status = XTmrCtr_Initialize(&InstancePtr, TIMER_DEVICE_ID);
    if(Status != XST_SUCCESS)
        xil_printf("%d\n", Status);

    //2. set AXI timer options (Auto reload and counting up )
    XTmrCtr_SetOptions(&InstancePtr, TIMER_COUNTER_0,  XTC_AUTO_RELOAD_OPTION);

    //Set the interrupt handler function
   // XTmrCtr_InterruptHandler(&InstancePtr);
    
    //3. Start and calibrate the counter
    XTmrCtr_Start(&InstancePtr, TIMER_COUNTER_0);
    u32 StartTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
    u32 EndTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);

    u32 Calibration = EndTime -  StartTime ; //give the overhead to go through the interconnect ( communication between microblaze and the timer IP)
    //xil_printf("%d\n", Calibration);

    // StartTime = 0;
    // EndTime = 0;
    // //start
    // StartTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
    // matMul(A, B, C);
    // EndTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
    // u32 Duration = (EndTime -  StartTime - Calibration); //time to run the matrix multiplication in software 8820. lookup variable in symbol table??
    // xil_printf("%dn\n", Duration);

    
    //end

//     StartTime = 0;
//     EndTime = 0;
//    u32 Duration = 0;

//     StartTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
//     matMul_simpleCpu(A, B, D);
//     EndTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
//     Duration = (EndTime -  StartTime - Calibration) ;
//     xil_printf("%dn\n", Duration);

    StartTime = 0;
    EndTime = 0;
    u32 Duration = 0;

    StartTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
   matMul_simpleCpu_add_Mult(A, B, E);
    EndTime = XTmrCtr_GetValue(&InstancePtr, TIMER_COUNTER_0);
    Duration = (EndTime -  StartTime - Calibration) ;
    xil_printf("%dn\n", Duration);
    while(1) {
    XGpio_DiscreteWrite(&Gpio, GPIO_CHANNEL, Duration);
    }


   // xil_printf("RES = %d\n", compareMatrices(C, E));
    cleanup_platform();
    return 0;
}