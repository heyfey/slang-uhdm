// § ifaceTwoPkgTdNameOrder186 (a repeated typedef name abstains; an explicit import beside abstains in x05)
package p1;
  typedef struct packed { logic a; } a_t;
  typedef struct packed { logic b; } c_t;
endpackage
package p2;
  typedef struct packed { logic c; } a_t;
  typedef struct packed { logic d; } b_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  c_t x;
  b_t y;
endinterface
module top;
  bus_if b();
endmodule
