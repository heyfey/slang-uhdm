// § parenCastWidthRefPkgBare207 § pcwElabKeepsClaim207v (a generate scope reading the cast parameter; per-instance overrides of a parameter defaulted from the width)
package pk;
  localparam aw = 10;
  localparam base = (aw)'('h3ff);
endpackage
module sub import pk::*; #(parameter int W = aw) (output logic [W-1:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    assign o = base[W-1:0];
  end
endmodule
module top (output logic [9:0] a, output logic [3:0] b, output logic [5:0] c);
  sub u1 (.o(a));
  sub #(.W(4)) u2 (.o(b));
  sub #(6) u3 (.o(c));
endmodule
