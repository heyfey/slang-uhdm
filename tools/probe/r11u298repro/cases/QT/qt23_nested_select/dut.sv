// § pkgQualBoundSpanTernary298
// a ternary bound inside another select's index and inside a cast in a concatenation
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, input logic [7:0] m [4], output logic [31:0] y);
  always_comb y = {m[d[(pk::DC ? pk::DC : pk::N)-1:0]], 24'(d[(pk::N ? pk::N : pk::DC):1])};
endmodule
