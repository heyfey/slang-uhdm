// § unitImportCopyOwnTsRef214 — a $unit-imported parameter typed by another package's typedef, and one typed by the package's own enum
package t;
  typedef logic [5:0] w_t;
endpackage
package p;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter t::w_t WP = 6'd33;
  parameter e_t EP = E2;
  parameter N = WP + 1;
endpackage
import p::*;
module top(output int o);
  assign o = N + int'(EP);
endmodule
