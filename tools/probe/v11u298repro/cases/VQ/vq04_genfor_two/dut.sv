// § pkgQualBoundSpanTernary298
// a ternary bound with a genvar condition and a parameter condition in a two-level generate
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [31:0] y [2][2]);
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      assign y[i][j] = 32'(d[(i ? pk::N : pk::M):(j ? pk::DC : 0)]);
    end
  end
endmodule
