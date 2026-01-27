`timescale 1ns/1ps

module tb_axim_reg;

    //-------------------- PARAMETERS--------------------
    parameter ADDRESS_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    localparam PERIOD = 4; // 250 MHz
    localparam NUM_TESTS = 10;

    
    //------------ DUT SIGNALS---------------------------
    reg clk=0;
    reg rstn;
    // AXI Write Address Channel
    reg [ADDRESS_WIDTH-1:0] s_axi_awaddr;
    reg                     s_axi_awvalid;
    wire                    s_axi_awready;
    // AXI Write Data Channel
    reg [DATA_WIDTH-1:0]    s_axi_wdata;
    reg                     s_axi_wvalid;
    wire                    s_axi_wready;
    // AXI Write Response Channel
    wire [1:0]              s_axi_bresp;
    wire                    s_axi_bvalid;
    reg                     s_axi_bready;
    // Output Register
    wire [DATA_WIDTH-1:0]   output_reg;

    //-----------------TEST DATA ARRAYS--------------------
    reg [ADDRESS_WIDTH-1:0] test_addresses [0:NUM_TESTS-1];
    reg [DATA_WIDTH-1:0]    test_data [0:NUM_TESTS-1];
    reg [1:0]               expected_resp [0:NUM_TESTS-1];
    reg [DATA_WIDTH-1:0]    expected_output [0:NUM_TESTS-1];

    reg [NUM_TESTS:0] errors, passed, i;

  
    //---------------DUT INSTANTIATION-------------------------
    axim_reg #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        // Write Address Channel
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        // Write Data Channel
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        // Write Response Channel
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        // Output Register
        .output_reg(output_reg)
    );

    //------------CLOCK GENERATION-----------------
    always #(PERIOD/2) clk = ~clk;
    

    // ----------------------------------------------------
    // INITIALIZE TEST VECTORS
    // ----------------------------------------------------
    initial begin
        // Test case 0: Valid write address 0 , data = 100
        test_addresses[0] = 32'h0000_0000;
        test_data[0] = 32'd100;  // 
        expected_resp[0] = 2'b00; // OKAY
        expected_output[0] = 32'd100;

        // Test case 1: Valid write address, data = 250
        test_addresses[1] = 32'h0000_0000;
        test_data[1] = 32'd250;
        expected_resp[1] = 2'b00; // OKAY
        expected_output[1] = 32'd250;

        // Test case 2: Invalid address (non-zero) , data = 500
        test_addresses[2] = 32'h0000_0004;
        test_data[2] = 32'd500;
        expected_resp[2] = 2'b10; // error
        expected_output[2] = 32'd250; // Should not change

        // Test case 3: Valid address , data = 750
        test_addresses[3] = 32'h0000_0000; 
        test_data[3] = 32'd750;
        expected_resp[3] = 2'b00; // OKAY
        expected_output[3] = 32'd750;

        // Test case 4: Invalid address  , data = 333
        test_addresses[4] = 32'h0000_FFFF;
        test_data[4] = 32'd333;
        expected_resp[4] = 2'b10; // error
        expected_output[4] = 32'd750; // Should not change

        // Test case 5: All 1
        test_addresses[5] = 32'h0000_0000;
        test_data[5] = 32'd1;
        expected_resp[5] = 2'b00; // OKAY
        expected_output[5] = 32'd1;

        // Test case 6: All 0
        test_addresses[6] = 32'h0000_0000;
        test_data[6] = 32'd0;
        expected_resp[6] = 2'b00; // OKAY
        expected_output[6] = 32'd0;

        // Test case 7: Valid address, data = 555
        test_addresses[7] = 32'h0000_0000;
        test_data[7] = 32'd555;
        expected_resp[7] = 2'b00; // OKAY
        expected_output[7] = 32'd555;

        // Test case 8: Invalid address , data = 888
        test_addresses[8] = 32'h1234_5678;
        test_data[8] = 32'd888;
        expected_resp[8] = 2'b10; // error
        expected_output[8] = 32'd555; // 

        // Test case 9: valid write
        test_addresses[9] = 32'h0000_0000;
        test_data[9] = 32'd42;
        expected_resp[9] = 2'b00; // OKAY
        expected_output[9] = 32'd42;
    end

    // ----------------------------------------------------
    // AXI WRITE TRANSACTION TASK
    // ----------------------------------------------------
    task axi_write;
        input [ADDRESS_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        input [1:0] exp_resp;
        input [DATA_WIDTH-1:0] exp_output;
        begin
            // Start address phase
            @(posedge clk);
            s_axi_awaddr <= addr;
            s_axi_awvalid <= 1'b1;

            // Wait for address ready
            wait (s_axi_awready)
	    @(posedge clk);
            s_axi_awvalid <= 1'b0;

            // Start data phase
	    s_axi_wdata <= data;
            s_axi_wvalid <= 1'b1;
            
            // Wait for data ready
            
            wait (s_axi_wready)
	    @(posedge clk);
            s_axi_wvalid <= 1'b0;

            // Wait for response
            s_axi_bready <= 1'b1;
            wait (s_axi_bvalid)
            
            // Response received
           // @(posedge clk);
           // s_axi_bready = 1'b0;

	 // repeat(2) @(posedge clk);

	  // Check response
            if (s_axi_bresp !== exp_resp) begin
                $display("%0t ERROR: Response mismatch! Got %b, expected %b", $time, s_axi_bresp, exp_resp);
                errors = errors + 1;
            end else begin
                $display(" %0t PASS: Response = %b", $time, s_axi_bresp);
            end

            // Check output register
            if (output_reg !== exp_output) begin
                $display("%0t ERROR: Output mismatch! Got %0d, expected %0d", $time, output_reg, exp_output);
                errors = errors + 1;
            end else begin
                $display("%0t  PASS: Output = %0d", $time, output_reg);
                passed = passed + 1;
            end

           @(posedge clk);
           s_axi_bready <= 1'b0;
           repeat(2) @(posedge clk);
        end
    endtask

    // ----------------------------------------------------
    // TEST SEQUENCE
    // ----------------------------------------------------
    initial begin
        // Initialize signals
        rstn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        errors = 0;
        passed = 0;

        // Reset sequence
        repeat (5) @(posedge clk);
        rstn = 1;
        repeat (5) @(posedge clk);

        // Run all test cases
	// Run all test cases
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            axi_write(test_addresses[i], test_data[i],  expected_resp[i], expected_output[i]);
        end
       /*
        $display("========================================");
        $display("Total tests: %0d", NUM_TESTS);
        $display("Passed:      %0d", passed);
        $display("Failed:      %0d", errors);
        */
        if (errors == 0) begin
            $display("\n*** ALL TESTS PASSED! ***\n");
        end

        #1000;
        $finish;
    end


endmodule
