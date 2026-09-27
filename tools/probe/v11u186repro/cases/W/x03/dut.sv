// § ifaceTwoPkgTdNameOrder186 (a typedef of the second package names the first's type)
package p1;
  typedef struct packed { logic a; } q_t;
endpackage
package p2;
  typedef p1::q_t e_t;
  typedef struct packed { p1::q_t f; } d_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  q_t x;
  d_t y;
  e_t z;
endinterface
module top;
  bus_if b();
endmodule
