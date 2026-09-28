// § pkgFoldAtLeadingLeaf191 — fresh controls: a ternary on a non-constant-foldable condition shape, a module parameter, an unparenthesized plain sum
package p;
  parameter int W = 4;
  parameter int E = W + 1;
  parameter int F = (W);
endpackage
module top #(parameter int Q = p::W == 4 ? 2 : 3) (output int o);
  localparam int R = Q == 2 ? p::W : 1;
  assign o = p::E + p::F + Q + R;
endmodule
