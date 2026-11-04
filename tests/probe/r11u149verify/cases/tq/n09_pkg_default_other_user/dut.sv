// § defNetTypeParamPackedDim144
package p;
  typedef struct packed { logic [3:0] a; logic b; } d_t;
endpackage
module other(input p::d_t i, output logic [4:0] o);
  assign o = i;
endmodule
module dut #(parameter type dtype = p::d_t) (input logic clk, output logic [4:0] o);
  dtype [1:0] mem;
  always_ff @(posedge clk) mem <= '0;
  other u(.i(mem[0]), .o(o));
endmodule
