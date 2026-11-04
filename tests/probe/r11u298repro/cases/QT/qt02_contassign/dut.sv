// § pkgQualBoundSpanTernary298
// a ternary in a part-select bound in a continuous assignment
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y);
  assign y = 32'(d[(pk::DC ? pk::N : pk::DC)-1:0]);
endmodule
