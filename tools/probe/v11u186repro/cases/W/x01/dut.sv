// § ifaceTwoPkgTdNameOrder186 (header imports)
package p1;
  typedef logic [3:0] c_t;
  typedef struct packed { logic a; } a_t;
endpackage
package p2;
  typedef enum logic { B0, B1 } b_t;
endpackage
interface bus_if import p1::*, p2::*; ();
  a_t x;
  b_t y;
  c_t z;
endinterface
module top;
  bus_if b();
endmodule
