// § pkgQualBoundSpanTernary298
// a ternary bound in a net declaration assignment
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  wire [31:0] w = 32'(d[(pk::DC ? pk::DC : pk::N)-1:0]);
  assign y = w;
endmodule
