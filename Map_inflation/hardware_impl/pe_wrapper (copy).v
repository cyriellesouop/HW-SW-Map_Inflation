`timescale 1ns/1ps

module pe_wrapper #(
    parameter KERNEL_SIZE  = 3,
    parameter DATA_WIDTH   = 8,
    parameter WEIGHT_WIDTH = 8
)(
    input  clk,
    input  rstn,
    input  en,
    
    input  [DATA_WIDTH * KERNEL_SIZE - 1 : 0]                                    dataIn,    // input contains KERNEL_SIZE pixels
    input  [(WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE) - 1 : 0]                  weightsIn, // KERNEL_SIZE * KERNEL_SIZE weights concatenated
    
    output   [(DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE) * KERNEL_SIZE - 1 : 0] dataOut,    // Concatenated adder results  Width = (Sum width) * KERNEL_SIZE
    output dataOut_done
);

    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam SUM_WIDTH  = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;
    localparam ROW_STRIDE = DATA_WIDTH * KERNEL_SIZE;
    // 2. Total Latency Calculation:
	// Vertical propagation: (KERNEL_SIZE-1) * 2 cycles
	// Adder tree latency: 2 cycles
     localparam TOTAL_DONE_DELAY = 2;
    //localparam TOTAL_DONE_DELAY = ((KERNEL_SIZE-1) * 2) + 2;

   // signals to manage all the PE input and output ports of each row 
    reg  [KERNEL_SIZE:0]                       k;
    reg  [DATA_WIDTH-1:0]                      input_row_regs [0:KERNEL_SIZE-1];  //  contains inputs of one row of PEs 

   // Total bits: (Number of boundaries) * (Pixels per boundary) * (Bits per pixel)
    wire [ROW_STRIDE * (KERNEL_SIZE + 1) - 1 : 0] vertical_pixel_bus;

    wire [KERNEL_SIZE-1:0] all_row_adder_en; // Define a wire to collect the status of every adder_en of all the rows


   // 1. Input row Registration : we slide the dataIn into kernel size elements
    always @(posedge clk) begin
        if (!rstn) begin
            for ( k = 0; k < KERNEL_SIZE; k = k + 1)
                input_row_regs[k] <= {DATA_WIDTH{1'b0}};
        end
       	else if (en) begin
            for (k = 0; k < KERNEL_SIZE; k = k + 1)
                input_row_regs[k] <= dataIn[k*DATA_WIDTH +: DATA_WIDTH];
        end
    end

    // 2. Vertical Connection Bus
    // This loop is the "Bridge" between the Input Registers and the first row of the Processing Elements (PEs)
    genvar init_c;
    generate
        for (init_c = 0; init_c < KERNEL_SIZE; init_c = init_c + 1) begin 
            assign vertical_pixel_bus[init_c*DATA_WIDTH +: DATA_WIDTH] = input_row_regs[init_c];
        end
    endgenerate

    // 3. PE Grid and Adder Tree
    genvar r, c;
    generate
        for (r = 0; r < KERNEL_SIZE; r = r + 1) begin 
            
            // Declarations INSIDE the loop: Each row gets its own unique set
            wire [KERNEL_SIZE - 1 : 0] row_pe_dones;                         //Wire to collect "done" status from each PE in this row
            wire [PRODUCT_WIDTH * KERNEL_SIZE - 1 : 0] current_row_products; // Wire to collect products(PE ooutput) for this row's adder tree
            wire row_adder_en = &row_pe_dones; // Local to this row          // signal to enable the adder of a specific row
	    // The adder for this row is only enabled when ALL PEs in the row are done

	    // EXPORT the local enable to our collection wire
            assign all_row_adder_en[r] = row_adder_en;

            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin 
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .WEIGHT_WIDTH(WEIGHT_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .rstn(rstn),
                    .pe_en(en),
		     
		   // (r * ROW_STRIDE) moves the pointer to the start of the current row's data.
		   // (c * DATA_WIDTH) moves the pointer to the specific column in that row.
                    .pe_input(vertical_pixel_bus[(r * ROW_STRIDE) + (c * DATA_WIDTH) +: DATA_WIDTH]),

                    .pe_weight(weightsIn[(r*KERNEL_SIZE + c)*WEIGHT_WIDTH +: WEIGHT_WIDTH]), //assigns a unique weight to every single PE. In a 3x3 grid, Row 1, Col 0 is the 4th weight (index 3).

                    .pe_pixel_out(vertical_pixel_bus[((r+1) * ROW_STRIDE) + (c * DATA_WIDTH) +: DATA_WIDTH]), 
                    .pe_output(current_row_products[c*PRODUCT_WIDTH +: PRODUCT_WIDTH]), //Send the PE result to the c-th slot of this row's product bus, which is connected to the adder tree
                    .pe_done(row_pe_dones[c]) // Connect individual done signal
                );
            end

            // Adder Tree for the row
            adder_tree #(
                .KERNEL_SIZE(KERNEL_SIZE),
                .DATA_WIDTH(DATA_WIDTH),
                .WEIGHT_WIDTH(WEIGHT_WIDTH)
            ) row_sum_adder (
                .clk(clk),
                .rstn(rstn),
                .adder_en(row_adder_en), // Enabled by the row's combined done signal
                .adder_dataIn(current_row_products),
                .adder_dataOut(dataOut[r*SUM_WIDTH +: SUM_WIDTH])
            );
        end
    endgenerate

    // --- 4. Done Signal Synchronization ---
      wire first_row_ready = all_row_adder_en[0]; // Now we simply look at the enable signal of the first adder row. 
   // wire last_row_ready = all_row_adder_en[KERNEL_SIZE-1]; // Now we simply look at the enable signal of the last adder row. 

    delay #(
        .LATENCY(TOTAL_DONE_DELAY),
        .WIDTH(1)
    ) delay_inst (
        .clk(clk),
        .rstn(rstn),
        .dataIn(first_row_ready),
        .dataOut(dataOut_done)
    );
   
   
endmodule
