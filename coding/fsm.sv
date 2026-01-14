`timescale 1ns/1ps

module fsm 
(
 input clk,
 input rstn,

 input load_weight_en,
 input load_weight_done,

 input load_data_exec_done,

 output reg  adder_en,
 input  adder_done,

 input write_output_done,

 input is_last
);

typedef enum {IDLE, LOAD_WEIGHT, LOAD_DATA_EXEC, ADD_OUT, INTER, WRITE_OUT} state_t;

state_t state, next_state;

//control flow
  always@(posedge clk) begin
    
    if(~rstn) 
        state <= IDLE;
     else
         state <= next_state;
  end


     always @(*) begin
        next_state = state;
	case(state)
	   IDLE          : if (load_weight_en)
	                       next_state <= LOAD_WEIGHT;
	   LOAD_WEIGHT   : if (load_weight_done)
	                       next_state <= LOAD_DATA_EXEC;
	   LOAD_DATA_EXEC: if(load_data_exec_done)
	                       next_state <= ADD_OUT;
	   ADD_OUT       : if(adder_done)
		               next_state <= WRITE_OUT;
           WRITE_OUT     : if(write_output_done)
		                next_state <= INTER;
	   INTER         : if(is_last)
		               next_state <= IDLE;
	                   else
		               next_state <= LOAD_DATA_EXEC;
	endcase 
     end


   always @(posedge clk) begin
      if (~rstn) begin
         adder_en <= 0;
      end else begin
        case (next_state)
          IDLE:          adder_en <= 0;
          LOAD_WEIGHT:   adder_en <= 0;
          LOAD_DATA_EXEC:adder_en <= 1;
          ADD_OUT:       adder_en <= 0;
          WRITE_OUT:  adder_en <= 0;
          default:       adder_en <= 0;
        endcase
     end
  end
endmodule
