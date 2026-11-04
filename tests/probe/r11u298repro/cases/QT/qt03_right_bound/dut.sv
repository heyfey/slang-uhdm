// § pkgQualBoundSpanTernary298
// the ternary on the right bound
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  always_comb y = 32'(d[7:(pk::N > 2 ? pk::N : pk::DC)]);
endmodule
