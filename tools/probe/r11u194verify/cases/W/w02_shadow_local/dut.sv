// § ifaceTwoPkgTdNameOrder186: an interface wildcard-importing two packages where a local typedef shadows one imported name, and the interface's own typedef sits between the imported names
package p1;
  typedef logic [1:0] a_t;
  typedef logic [2:0] m_t;
endpackage
package p2;
  typedef logic [3:0] b_t;
  typedef logic [4:0] z_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  typedef logic [5:0] m_t;
  typedef logic [6:0] k_t;
  a_t a;
  b_t b;
  m_t m;
  k_t k;
  z_t z;
endinterface
module top;
  bus_if bi ();
endmodule
