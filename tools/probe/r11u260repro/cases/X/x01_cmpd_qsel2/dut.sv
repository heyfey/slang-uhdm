// § pkgSelPsBoundColonsElab260 (decode: Earlgrey testflags #216212, a compound assignment's two-level package-qualified select)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
endpackage
module m #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  always_comb begin : p_x
    q = d;
    q ^= cp::RC[0][W-1:0];
  end
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
