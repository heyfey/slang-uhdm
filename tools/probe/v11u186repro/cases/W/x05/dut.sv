// § ifaceTwoPkgTdNameOrder186 (an explicit import beside two wildcards abstains)
package p1;
  typedef struct packed { logic a; } c_t;
  typedef struct packed { logic b; } a_t;
endpackage
package p2;
  typedef struct packed { logic c; } b_t;
  localparam int K = 1;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  import p2::K;
  a_t x;
  b_t y;
endinterface
module top;
  bus_if b();
endmodule
