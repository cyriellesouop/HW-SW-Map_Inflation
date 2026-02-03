`timescale 1ns/1ps

module tb_pe_wrapper;

    // Parameters
    parameter KERNEL_SIZE  = 3;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    
    localparam PRODUCT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH;
    localparam SUM_WIDTH  = PRODUCT_WIDTH + KERNEL_SIZE; 
    localparam PERIOD     = 4;
    localparam NUM_TESTS  = 5;
    localparam TOTAL_WEIGHTS = KERNEL_SIZE * KERNEL_SIZE;
    localparam VERTICAL_SKEW = 2;  // number of clock cycles it takes for data to propagate from one row to the next row in your PE array
    localparam ADDITIONAL_DELAY = 1; // Additional pipeline delay observed

    // Signals
    reg clk = 0;
    reg rstn;
    reg en;
    
    // Inputs
    reg [DATA_WIDTH * KERNEL_SIZE - 1 : 0] dataIn;
    reg [(WEIGHT_WIDTH * TOTAL_WEIGHTS) - 1 : 0] weightsIn;
    
    // Outputs
    wire [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] dataOut;
    wire dataOut_done;
    wire ready; 

    // Memory arrays
    reg [WEIGHT_WIDTH-1:0] weights_mem [0:TOTAL_WEIGHTS-1];
    reg [DATA_WIDTH * KERNEL_SIZE - 1 : 0] dataIn_mem [0:NUM_TESTS-1];
    reg [SUM_WIDTH - 1 : 0] exp_mem [0:(NUM_TESTS * KERNEL_SIZE) - 1];
    
    // Capture and verification
    reg [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] results_captured [0:NUM_TESTS + KERNEL_SIZE];
    integer cap_ptr = 0, errors = 0, cycle, test_id;
    integer i, r, c;
    
    // Declare verification variables at module level
    reg [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] expected_bus;
    reg [(SUM_WIDTH * KERNEL_SIZE) - 1 : 0] actual_bus;
    reg [SUM_WIDTH-1:0] exp_val, act_val;

  

    // DUT Instance
    pe_wrapper #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .dataIn(dataIn),
        .weightsIn(weightsIn),
        .dataOut(dataOut),
        .dataOut_done(dataOut_done),
	.ready(ready)
    );

    // Clock Generation
    always #(PERIOD/2) clk = ~clk;

    // Continuous Capture Logic - capture on rising edge of done signal
    reg dataOut_done_prev;
    
   always @(posedge clk) begin
        if (rstn && dataOut_done) begin
            $display("DataOut T=%0t  %0b", $time,  dataOut); 
            $display("Output T=%0t | Row2: %0d | Row1: %0d | Row0: %0d", $time,  dataOut[2*SUM_WIDTH +: SUM_WIDTH], dataOut[1*SUM_WIDTH +: SUM_WIDTH], dataOut[0*SUM_WIDTH +: SUM_WIDTH]);
        end
    end

    // Main Test Sequence
    initial begin
      
        // Initialize
        rstn = 0;
        en   = 0;
        dataIn = 0;
        
        // 1. Define Fixed Weights (all weights = row + 1)
        $display("--- Initializing Weights ---");
        for (r = 0; r < KERNEL_SIZE; r = r + 1) begin
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                weights_mem[r * KERNEL_SIZE + c] = r + 1;
                weightsIn[(r * KERNEL_SIZE + c) * WEIGHT_WIDTH +: WEIGHT_WIDTH] = r + 1;
            end
            $display("Row %0d weights: [%0d %0d %0d]", r, r+1, r+1, r+1);
        end

        // Reset sequence
        repeat(5) @(posedge clk);
        rstn = 1;
        repeat(5) @(posedge clk); 

	// Wait for ready signal
        wait(ready == 1'b1);
        en = 1;
        @(posedge clk);

        // 2. Feed Input Data 
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            // Create input: [i, i+1, i+2]
            for (c = 0; c < KERNEL_SIZE; c = c + 1) begin
                dataIn[c*DATA_WIDTH +: DATA_WIDTH] = i + c ;
            end
           
            @(posedge clk);
            $display("%0t Test %0d: dataIn = [%0d %0d %0d]",$time, i, i, i+1, i+2); 
        end

        repeat(KERNEL_SIZE * VERTICAL_SKEW + 5) @(posedge clk);
        en = 0;
        @(posedge clk);
        
        // Wait for all captures
        wait(cap_ptr >= NUM_TESTS+ (KERNEL_SIZE - 1));  // number of cycle we need for ALL rows to see ALL tests
        repeat(5) @(posedge clk);
        
        // Only check cycles that should have valid data
        // Last valid data appears at cycle: (NUM_TESTS - 1) + (VERTICAL_SKEW * (KERNEL_SIZE - 1)) + ADDITIONAL_DELAY
        for (cycle = 0; cycle < cap_ptr && cycle < NUM_TESTS + KERNEL_SIZE; cycle = cycle + 1) begin
            actual_bus = results_captured[cycle];
    
            $display("%0t actual_bus %0d: %h",
         $time, cycle, results_captured[cycle]);

            
        end
   
        #200;
        $finish;
    end

endmodule
