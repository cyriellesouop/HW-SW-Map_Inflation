`timescale 1ns/1ps

module tb_adder_tree;

    // -----------------------------------------------------
    // Parameters (match your design)
    // -----------------------------------------------------
    parameter PERIOD = 4;
    parameter WEIGHT_WIDTH = 1;
    parameter DATA_WIDTH   = 8;
    parameter KERNEL_SIZE  = 3;
    localparam RESULT_WIDTH = DATA_WIDTH + WEIGHT_WIDTH; 

    // -----------------------------------------------------
    // DUT signals
    // -----------------------------------------------------
    reg clk = 0;
    reg rstn;
    reg adder_en;
    reg [(RESULT_WIDTH*KERNEL_SIZE)-1:0] adder_dataIn;
    wire [(RESULT_WIDTH)+KERNEL_SIZE-1:0] adder_dataOut;
    wire adder_done;

    // -----------------------------------------------------
    // Instantiate DUT
    // -----------------------------------------------------
    adder_tree #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rstn(rstn),
        .adder_en(adder_en),
        .adder_dataIn(adder_dataIn),
        .adder_dataOut(adder_dataOut),
        .adder_done(adder_done)
    );

    // -----------------------------------------------------
    // Clock generation
    // -----------------------------------------------------
    always #(PERIOD/2) clk = ~clk; // 4 ns period (250 MHz)

    // -----------------------------------------------------
    // Task: generate random input values (0–16 range)
    // -----------------------------------------------------
    task generate_random_inputs;
       reg [KERNEL_SIZE-1:0] i;
        reg [RESULT_WIDTH-1:0] temp;
        begin
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                temp = $urandom_range(0, 4);  // generate 0–16
                adder_dataIn[(i+1)*RESULT_WIDTH-1 -: RESULT_WIDTH] = temp;
            end
        end
    endtask

    // -----------------------------------------------------
    // Function: software golden model (expected sum)
    // -----------------------------------------------------
    function [(RESULT_WIDTH)+KERNEL_SIZE-1:0] expected_sum;
        input [(RESULT_WIDTH*KERNEL_SIZE)-1:0] in_data;
        reg [KERNEL_SIZE-1:0] i;
        reg [RESULT_WIDTH-1:0] unpacked [0:KERNEL_SIZE-1];
        reg [(RESULT_WIDTH+KERNEL_SIZE)-1:0] sum;
        begin
            for (i = 0; i < KERNEL_SIZE; i = i + 1)
                unpacked[i] = in_data[(i+1)*RESULT_WIDTH-1 -: RESULT_WIDTH];
            
            sum = 0;
            for (i = 0; i < KERNEL_SIZE; i = i + 1)
                sum = sum + unpacked[i];
            
            expected_sum = sum;
        end
    endfunction

    // -----------------------------------------------------
    // Test sequence
    // -----------------------------------------------------
    integer test;
    reg [(RESULT_WIDTH+KERNEL_SIZE)-1:0] result;

    initial begin
        // Initialize
        rstn = 0;
        adder_en = 0;
        adder_dataIn = 0;
        repeat (2) @(posedge clk);
        rstn = 1;
        repeat (2) @(posedge clk);

        // Run multiple test cases
        for (test = 0; test < 10; test = test + 1) begin
            generate_random_inputs();
	    repeat (2) @(posedge clk);
	    result = expected_sum(adder_dataIn);
	    @(posedge clk);
            $display("----------------------------------------------------");
            $display("TEST %0d: adder_dataIn = %0b", test, adder_dataIn);
            $display("Expected sum =  %0b", result);

            // Start computation
            adder_en = 1;
            @(posedge clk);
            adder_en = 0;
	    repeat (2) @(posedge clk);

            // Wait for done
            wait(adder_done == 1);
            @(posedge clk);

            // Check result
            if (adder_dataOut === result) begin
                $display("PASS: Output matches expected result! %b ", adder_done);
            end else begin
                $display("FAIL: Expected %0b, DUT %0b", result, adder_dataOut);
            end
        end

        $display("----------------------------------------------------");
        $display("All test cases finished!");
        #100;
        $finish;
    end

endmodule

