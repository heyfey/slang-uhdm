// § defNetTypeParamPackedDim144
package p;
  typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
endpackage
module dut #(parameter type dtype = p::u_t) (input logic clk, output logic [3:0] o);
  dtype [1:0] mem;
  always_ff @(posedge clk) mem <= '0;
  assign o = mem[0];
endmodule
