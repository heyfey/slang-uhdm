// § pkgQualBoundSpanTernary298
// a comparison condition and operation branches in a part-select bound
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  always_comb y = 32'(d[(pk::N > 2 ? pk::M + 1 : pk::N - 1):0]);
endmodule
