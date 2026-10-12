// § pkgQualBoundSpanTernary298
// the ternary nested in an operation in a parenthesis with the qualified read in both branches and a cast
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  assign y = 32'(d[((pk::DC ? int'(pk::N) : pk::M) * 2) - 1:0]);
endmodule
