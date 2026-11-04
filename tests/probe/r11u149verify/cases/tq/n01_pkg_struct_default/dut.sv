// § defNetTypeParamPackedDim144
package p;
  typedef struct packed { logic [3:0] a; logic b; } d_t;
endpackage
module dut #(parameter type dtype = p::d_t, parameter int D = 2) (input logic clk, output logic [4:0] o);
  dtype [D-1:0] mem;
  always_ff @(posedge clk) mem <= '0;
  assign o = mem[0];
endmodule
