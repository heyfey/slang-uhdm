// § defNetTypeParamPackedDim144 (pass 137's unpacked-dimension arm of the same site, a package typedef default)
package p;
  typedef struct packed { logic [3:0] a; logic b; } d_t;
endpackage
module dut #(parameter type dtype = p::d_t) (input logic clk, output logic [4:0] o);
  dtype mem [2];
  always_ff @(posedge clk) mem[0] <= '0;
  assign o = mem[0];
endmodule
