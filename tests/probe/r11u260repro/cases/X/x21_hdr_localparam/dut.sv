// § pkgSelPsBoundColonsElab260 (a header localparam in the bound)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
endpackage
module m #(parameter int W = 8, localparam int L = W - 1) (input logic [W-1:0] d, output logic [W-1:0] q);
  always_comb q = cp::RC[1][L:0];
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
