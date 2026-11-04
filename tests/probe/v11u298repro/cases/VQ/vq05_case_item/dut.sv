// § pkgQualBoundSpanTernary298
// a ternary bound in a case expression, an if condition and a for bound
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module top (input logic [31:0] d, output logic [3:0] y);
  always_comb begin
    y = '0;
    case (d[(pk::N ? pk::DC : pk::M):0])
      4'h1: y = 4'h1;
      default: y = 4'h2;
    endcase
    if (d[(pk::DC ? pk::M : pk::N):1] != 0) y = 4'h3;
    for (int k = 0; k < d[(pk::N ? pk::N : pk::M):0]; k++) y = y + 1;
  end
endmodule
