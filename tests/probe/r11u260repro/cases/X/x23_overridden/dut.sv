// § pkgSelPsBoundColonsElab260 (an overridden header parameter)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
endpackage
module m #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  always_comb q = cp::RC[1][W-1:0];
endmodule
module top;
  logic [3:0] d, q;
  m #(.W(4)) u (.d(d), .q(q));
endmodule
