// § defNetTypeParamPackedDim144
package p;
  typedef struct packed { logic [3:0] a; logic b; } d_t;
  parameter d_t Z = '0;
endpackage
module dut #(parameter type dtype = p::d_t) (input logic clk, output logic [4:0] o);
  dtype [3:0] mem;
  always_ff @(posedge clk) mem <= '0;
  assign o = mem[0] ^ p::Z;
endmodule
