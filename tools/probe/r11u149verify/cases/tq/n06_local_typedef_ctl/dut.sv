// § defNetTypeParamPackedDim144
typedef struct packed { logic [3:0] a; logic b; } d_t;
module dut #(parameter type dtype = d_t) (input logic clk, output logic [4:0] o);
  dtype [1:0] mem;
  always_ff @(posedge clk) mem <= '0;
  assign o = mem[0];
endmodule
