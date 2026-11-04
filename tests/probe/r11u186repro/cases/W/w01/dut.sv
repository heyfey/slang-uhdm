// § ifaceTwoPkgTdNameOrder186
package p1;
  typedef struct packed { logic a; } c_t;
  typedef struct packed { logic b; } a_t;
endpackage
package p2;
  typedef struct packed { logic c; } b_t;
  typedef struct packed { logic d; } d_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  a_t x;
  b_t y;
endinterface
module top;
  bus_if b();
endmodule
