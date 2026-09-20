// g5 - the CORPUS WITNESS of the landed `aliasOfAlias0` guard, verbatim in
// shape: uhdm2rtlil test arrays03 declares `typedef reg8_t [0:3] reg2dim1_t;`
// at $unit scope and passes it as an ANSI input port.  Golden prints NO net
// type there, and must keep printing none.
typedef logic [0:3][7:0] reg2dim_t;
typedef logic  [7:0] reg8_t;
typedef reg8_t [0:3] reg2dim1_t;
module pcktest3 (input logic clk, input reg2dim_t in, input logic [1:0] ix,
                 output reg8_t out);
  always_ff @(posedge clk) out <= in[ix];
endmodule
module pcktest4 (input logic clk, input reg2dim1_t in, input logic [1:0] ix,
                 output reg8_t out);
  always_ff @(posedge clk) out <= in[ix];
endmodule
module dut (input logic clk, input logic [1:0] ix, output reg8_t o);
  reg2dim_t  a; reg2dim1_t b; reg8_t c, d;
  pcktest3 u3 (.clk(clk), .in(a), .ix(ix), .out(c));
  pcktest4 u4 (.clk(clk), .in(b), .ix(ix), .out(d));
  assign o = c | d;
endmodule
