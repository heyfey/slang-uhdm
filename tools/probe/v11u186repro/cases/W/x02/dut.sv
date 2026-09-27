// § ifaceTwoPkgTdNameOrder186 (three packages, one with no typedef, two instances, a modport)
package p1;
  typedef struct packed { logic a; } z_t;
  localparam int W = 3;
endpackage
package p2;
  typedef struct packed { logic [1:0] b; } m_t;
  typedef struct packed { logic c; } a_t;
endpackage
package p3;
  localparam int V = 2;
endpackage
interface bus_if;
  import p1::*;
  import p3::*;
  import p2::*;
  z_t x;
  m_t y;
  a_t w;
  modport mp(input x, output y);
endinterface
module sink(bus_if.mp b); endmodule
module top;
  bus_if b1();
  bus_if b2();
  sink s(.b(b1));
endmodule
