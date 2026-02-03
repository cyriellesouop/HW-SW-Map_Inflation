`timescale 1ns/1ps

module tb_weight_loader;

    // =====================================================
    // Parameters
    // =====================================================
    localparam WEIGHT_WIDTH = 8;
    localparam BUS_WIDTH    = 32;
    localparam NUM_ITERS    = 5;
    localparam MAX_BITS     = 128; // 4*4*8
    localparam PERIOD = 4;

    reg clk = 0;
    reg rstn;

    always #(PERIOD/2) clk = ~clk;

    // AXI Stream Signals
    reg  [BUS_WIDTH-1:0] s_axis_tdata;
    reg                  s_axis_tvalid;
    wire                 s_axis_tready;
    wire                 loading;
    wire [MAX_BITS-1:0]  weights_out;

    // DUT (Fixed kernel = 4)
    weight_loader #(
        .KERNEL_SIZE(4),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
	//inputs
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
	//outputs
        .weights_out(weights_out),
        .loading(loading)
    );

    // AXI send task
    task send_data;
        input [BUS_WIDTH-1:0] data;
        begin
            @(posedge clk);
            s_axis_tdata  <= data;
            s_axis_tvalid <= 1'b1;
	    wait(s_axis_tready);
            @(posedge clk);
            s_axis_tvalid <= 1'b0;
            s_axis_tdata  <= {BUS_WIDTH{1'bx}};
        end
    endtask

    // Test task
    task run_test;
        input integer KERNEL_SIZE;

        integer iter, beat, bit_i;
        integer REQUIRED_BITS;
        integer USED_TRANSFERS;
        integer TOTAL_TRANSFERS;
        integer dst_bit;
        reg [MAX_BITS-1:0] expected;
        reg [BUS_WIDTH-1:0] payload;
        reg error;

        begin
            REQUIRED_BITS   = KERNEL_SIZE*KERNEL_SIZE*WEIGHT_WIDTH;
            USED_TRANSFERS  = (REQUIRED_BITS + BUS_WIDTH - 1)/BUS_WIDTH;
            TOTAL_TRANSFERS = MAX_BITS / BUS_WIDTH; // always 4 because of the MAX_BITS value

            $display("Testing KERNEL_SIZE = %0d", KERNEL_SIZE);

            for (iter = 0; iter < NUM_ITERS; iter = iter + 1) begin
                expected = 0;

                s_axis_tvalid = 0;
                rstn = 0;
                repeat (5) @(posedge clk);
                rstn = 1;
                @(posedge clk);

                // Wait for loader
                wait (loading);

                // Send transfers
                for (beat = 0; beat < TOTAL_TRANSFERS; beat = beat + 1) begin
                    if (beat < USED_TRANSFERS)
                        payload = $random;
                    else
                        payload = 0;

                    // Ordered reference model (MSB-first)
                    for (bit_i = 0; bit_i < BUS_WIDTH; bit_i = bit_i + 1) begin
                   dst_bit = MAX_BITS - 1 - beat*BUS_WIDTH - bit_i;
                        if (dst_bit >= 0)
                            expected[dst_bit] = payload[BUS_WIDTH-1-bit_i];
                    end
                    send_data(payload);
                end

                // Wait for completion
                wait (!loading);
                repeat (2) @(posedge clk);

                error = 0;
                for (bit_i = 0; bit_i < REQUIRED_BITS; bit_i = bit_i + 1) begin
                    if (weights_out[bit_i] !== expected[bit_i])
                        error = 1;
                end

                if (error) begin
                    $display("FAIL | K=%0d | iter=%0d", KERNEL_SIZE, iter);
                    $display("Expected = %h", expected);
                    $display("Got      = %h", weights_out);
                   
                end else begin
                    $display("PASS | K=%0d | iter=%0d", KERNEL_SIZE, iter);
                    $display("Expected = %h", expected);
                    $display("Got      = %h", weights_out);
                end
            end
        end
    endtask

    // Test Sequence
    initial begin

        run_test(2);
        run_test(3);
        run_test(4);
	run_test(5);

        #200;
        $finish;
    end
endmodule
