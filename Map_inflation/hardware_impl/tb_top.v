`timescale 1ns/1ps

module tb_top;

    // Parameters matching the top module
    parameter KERNEL_SIZE  = 16;
    parameter DATA_WIDTH   = 8;
    parameter WEIGHT_WIDTH = 8;
    parameter DEPTH        = 4;
    parameter PTR_WIDTH    = 2;
    parameter BUS_WIDTH    = 32;
    
    localparam PERIOD = 4; //250 MHZ
    // Calculated parameters
    localparam SUM_WIDTH      = DATA_WIDTH + WEIGHT_WIDTH + KERNEL_SIZE;
    localparam DATAOUT_WIDTH  = SUM_WIDTH * KERNEL_SIZE;
    localparam WEIGHTIN_WIDTH = WEIGHT_WIDTH * KERNEL_SIZE * KERNEL_SIZE;
    localparam NUM_WEIGHT_TRANSFERS = (WEIGHTIN_WIDTH + BUS_WIDTH - 1) / BUS_WIDTH;
    
    
    reg clk=0;
    reg rstn;
    
    // Input
    reg  [BUS_WIDTH-1:0]     s_axis_tdata;
    reg                      s_axis_tvalid;
    wire                     s_axis_tready;
    
    // Output
    reg                      m_axis_tready;
    wire [DATAOUT_WIDTH-1:0] m_axis_tdata;
    wire                     m_axis_tvalid;
    
    // DUT
    top #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );
    
    // --------------Clock Generation --------------------------------
    always #(PERIOD/2) clk = ~clk;


    // Test variables
    integer i, j, k;
    reg [7:0] test_weights [0:KERNEL_SIZE*KERNEL_SIZE-1];
    reg [7:0] test_data [0:KERNEL_SIZE-1];

    // Verification variables
    integer num_errors;
    integer num_checks;
    reg [SUM_WIDTH-1:0] expected_results [0:KERNEL_SIZE-1];
    reg [SUM_WIDTH-1:0] actual_result;

      //function to compute expected results
       function   [SUM_WIDTH-1:0] calculate_expected_pe_output;
        input integer pe_index;
        input [7:0] data_row [0:KERNEL_SIZE-1];
        input [7:0] weights [0:KERNEL_SIZE*KERNEL_SIZE-1];
        
        integer idx;
        integer weight_base;
        reg [31:0] accumulator;
        
        begin
            accumulator = 0;
            weight_base = pe_index * KERNEL_SIZE;
            
            for (idx = 0; idx < KERNEL_SIZE; idx = idx + 1) begin
                accumulator = accumulator + (data_row[idx] * weights[weight_base + idx]);
            end
            
            calculate_expected_pe_output = accumulator[SUM_WIDTH-1:0];
        end
    endfunction

    // task to verify if the expected result match the DUT result
    task verify_output;
        input [DATAOUT_WIDTH-1:0] output_data;
        input integer row_number;
        reg [31:0] expected_sum;
        reg [SUM_WIDTH-1:0] extracted_result;
        integer pe_idx;
        integer weight_idx;

        begin
            $display("\n--- Verifying Output for Row %0d ---", row_number);

            // Check each PE output (KERNEL_SIZE results per row)
            for (pe_idx = 0; pe_idx < KERNEL_SIZE; pe_idx = pe_idx + 1) begin
                // Extract the result for this PE
                extracted_result = output_data[pe_idx*SUM_WIDTH +: SUM_WIDTH];

                // Calculate expected result: sum of (data[i] * weight[pe_idx][i])
                expected_sum = 0;
                for (k = 0; k < KERNEL_SIZE; k = k + 1) begin
                    weight_idx = pe_idx * KERNEL_SIZE + k;
                    expected_sum = expected_sum + (test_data[k] * test_weights[weight_idx]);
                end

                // Compare expected vs actual
                num_checks = num_checks + 1;

                if (extracted_result == expected_sum) begin
                    $display("%0t  PE[%0d]: PASS - Expected: %0d, Got: %0d", $time, pe_idx, expected_sum, extracted_result);
                end 
		else begin
                    $display("%0t  PE[%0d]: FAIL - Expected: %0d, Got: %0d", $time,pe_idx, expected_sum, extracted_result);
                    
		    num_errors = num_errors + 1;

                    // Show detailed calculation for debugging
                    $display(" %0t Debug: Data values used:", $time);
                    for (k = 0; k < KERNEL_SIZE; k = k + 1) begin
                        weight_idx = pe_idx * KERNEL_SIZE + k;
                        $display(" %0t data[%0d]=%0d * weight[%0d,%0d]=%0d = %0d",$time, k, test_data[k], pe_idx, k, test_weights[weight_idx], test_data[k] * test_weights[weight_idx]);
                    end
                end
            end
        end
    endtask




    
    // Main test sequence
    initial begin
        // Initialize signals
        rstn = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        m_axis_tready = 1;
        
        // Wait for a few cycles
        repeat(10) @(posedge clk);
        rstn = 1;
	repeat(3) @(posedge clk);
        
        
        //Load Weights
        
        // Initialize test weights by incrementing 
        for (i = 0; i < KERNEL_SIZE*KERNEL_SIZE; i = i + 1) begin
	      test_weights[i] = i;
           // test_weights[i] = i % 256;
        end
        
        // Send weights via AXI Stream
        for (i = 0; i < NUM_WEIGHT_TRANSFERS; i = i + 1) begin
            @(posedge clk);
            wait(s_axis_tready);
            
            s_axis_tvalid = 1;
            // Pack 4 weights into 32-bit bus
            s_axis_tdata = {test_weights[i*4+3], test_weights[i*4+2], test_weights[i*4+1], test_weights[i*4]};
            
            @(posedge clk);
            $display(" %0t Sent weight transfer No %0d/ on %0d: 0x%h", $time, i+1, NUM_WEIGHT_TRANSFERS, s_axis_tdata);
        end
        
        s_axis_tvalid = 0;
        repeat(5) @(posedge clk);
        
       // $display(" %0t Weight loading complete", $time);
        
        // Stream Input Data
        $display("\n %0t Streaming Input Data", $time);
        
        // Send multiple rows of data
        for (j = 0; j < 10; j = j + 1) begin
            // Prepare test data for this iteration
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                test_data[i] = (j + i) % 256; // this is to avoid overflow in case i+j is too big . input data should fit on 32bits. 
            end
            
            // Send data (4 transfers for 16 bytes)
            for (i = 0; i < KERNEL_SIZE/4; i = i + 1) begin
                @(posedge clk);
                wait(s_axis_tready);
                
                s_axis_tvalid = 1;
                s_axis_tdata = {test_data[i*4+3], test_data[i*4+2], test_data[i*4+1], test_data[i*4]};
                
                @(posedge clk);
            end
            
            s_axis_tvalid = 0;
            $display(" %0t Sent data row %0d", $time, j);
            
            // Small delay between rows
            repeat(3) @(posedge clk);
        end
        
        $display("\n %0t  Collecting Results",$time);
        
        m_axis_tready = 1;

	// Wait for and verify outputs
        for (j = 0; j < 10; j = j + 1) begin
            // Wait for valid output
            @(posedge clk);
            while (!m_axis_tvalid) @(posedge clk);

            // Reconstruct the test data used for this output
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                test_data[i] = (j  + i) % 256 ;
            end

            // Verify the output
            verify_output(m_axis_tdata, j);

            @(posedge clk);
        end
        
        // Wait for outputs
       /* repeat(1000) @(posedge clk);
            
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            wait(m_axis_tvalid);
                    
            $display("%0t - Received output %0d: m_axis_tdata = %0d",  $time, i, m_axis_tdata[SUM_WIDTH-1:0]);
                    
            @(posedge clk);
         end
	 */
        
        repeat(20) @(posedge clk);
	$display("Total Checks: %0d", num_checks);
        $display("Total Errors: %0d", num_errors);

        if (num_errors == 0) begin
            $display("*** TEST PASSED - All outputs correct! ***");
        end else begin
            $display("*** TEST FAILED - %0d errors detected ***", num_errors);
        end

	#50;
        
        $finish;
    end
    
    /*
    initial begin
        $monitor("%0t | rstn=%b | s_valid=%b | s_ready=%b | m_valid=%b | m_ready=%b", $time, rstn, s_axis_tvalid, s_axis_tready, m_axis_tvalid, m_axis_tready);
    end
    */
    

endmodule
