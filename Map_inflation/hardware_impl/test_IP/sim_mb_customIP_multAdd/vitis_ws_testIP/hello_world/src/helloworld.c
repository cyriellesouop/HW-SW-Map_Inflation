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
#include "unistd.h" 
#include <xil_io.h>
#include "xil_types.h"
#include <stdlib.h>
#include "../../platform/hw/sdt/drivers/myRegister_v1_0/src/myRegister.h"



int main()
{
    init_platform();

    xil_printf("Hello \n\r");

    u32 data = 0x0000000B ;
    u32 i=0;

    while(1) {

        // Small delay so you can trigger the ILA easily
       if( i<8){
            // This writes the data to the IP's AXI Lite Slave interface
            MYREGISTER_mWriteReg(XPAR_MYREGISTER_0_BASEADDR, MYREGISTER_S00_AXI_SLV_REG0_OFFSET, data);

            // Increment data to see changes on the ILA
            data++;
            i++;

            usleep(40000);
        }
    }



    
    cleanup_platform();
    return 0;
}
