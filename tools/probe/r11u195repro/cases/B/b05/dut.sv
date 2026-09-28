// § pkgFoldAtLeadingLeaf191 — fresh: typed and untyped package parameters with the leaf a literal, an unsized literal and a parameter
package p;
  parameter W = 4;
  parameter logic [7:0] G = W == 4 ? 8'h3 : 8'h0;
  parameter H = W == 4 ? 'd5 : 1;
  parameter int unsigned I = W == 4 ? W : 0;
endpackage
module top(output int o);
  import p::*;
  assign o = G + H + I;
endmodule
