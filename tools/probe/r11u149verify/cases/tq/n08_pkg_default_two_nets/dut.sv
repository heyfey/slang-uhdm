// § defNetTypeParamPackedDim144
package p;
  typedef struct packed { logic [3:0] a; logic b; } d_t;
endpackage
module dut #(parameter type dtype = p::d_t) (input logic clk, output logic [4:0] o);
  dtype [1:0] mem_n;
  dtype [3:0] mem_q;
  always_ff @(posedge clk) mem_q <= '0;
  assign mem_n = '0;
  assign o = mem_q[0] ^ mem_n[1];
endmodule
