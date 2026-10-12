// § pkgQualBoundSpanTernary298
// a ternary bound in a for-generate process
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic [31:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb y[i] = 32'(d[(pk::DC ? pk::DC : pk::N)-1:0]);
  end
endmodule
