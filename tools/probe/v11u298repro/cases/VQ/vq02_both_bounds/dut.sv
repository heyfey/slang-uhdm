// § pkgQualBoundSpanTernary298
// ternaries on both bounds of one part select, assign
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [7:0] y);
  assign y = 8'(d[(pk::DC ? pk::M : pk::N)+2:(pk::N == 3 ? pk::DC : pk::M)]);
endmodule
