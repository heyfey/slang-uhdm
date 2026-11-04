// § pkgSelPsBoundColonsElab260 (decode: Earlgrey testflags #216212, a compound assignment's one-level package-qualified part select)
package cp;
  parameter logic [63:0] AC = 64'hC0AC29B7C97C50DD;
endpackage
module m #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  always_comb begin : p_x
    q = d;
    q ^= cp::AC[W-1:0];
  end
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
