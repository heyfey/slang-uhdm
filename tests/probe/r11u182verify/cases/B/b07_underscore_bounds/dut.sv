// § boundLitWrittenDigits172
package p;
  typedef logic [1_5:0_0] h_t;
endpackage
module dut (input logic [1_000:0] a, output p::h_t o);
  logic [0_07:0] n;
  assign n = a[7:0];
  assign o = {n, n};
endmodule
