// (r11u191 N1082) a package parameter initialized by a ternary whose chosen arm is a parameter reference (flash_phy_pkg.sv 43)
package p;
  parameter int W = 4;
  parameter int L = $clog2(W);
  parameter int S = W == 1 ? 1 : L;
  parameter int T = W == 4 ? 7 : L;
  parameter int U = W != 4 ? 1 : L + 1;
endpackage
module top(output int o);
  import p::*;
  assign o = S + T + U;
endmodule
