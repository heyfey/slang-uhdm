// § pkgQualBoundSpanTernary298
// the ternary written through a macro
`define SEL(a, b) (pk::DC ? a : b)
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  always_comb y = 32'(d[`SEL(pk::DC, pk::N)-1:0]);
endmodule
