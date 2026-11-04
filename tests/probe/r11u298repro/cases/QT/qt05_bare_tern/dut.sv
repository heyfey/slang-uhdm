// § pkgQualBoundSpanTernary298
// the ternary as the whole bound
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  always_comb y = 32'(d[(pk::DC > 1 ? pk::N : pk::DC):0]);
endmodule
