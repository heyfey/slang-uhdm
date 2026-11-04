// § ifaceTwoPkgTdNameOrder186: one package imported in the interface header and one in the body, enum and struct typedefs, a modport using them, the interface a port of two modules
package pa;
  typedef enum logic [1:0] {RA, RB} r_e;
  typedef struct packed { logic x; } z_s;
endpackage
package pb;
  typedef struct packed { logic y; } m_s;
  typedef enum logic {TA, TB} b_e;
endpackage
interface bus_if import pa::*; ();
  import pb::*;
  r_e r;
  b_e b;
  m_s m;
  z_s z;
  modport mp (input r, b, output m, z);
endinterface
module snk (bus_if.mp p); endmodule
module top;
  bus_if bi ();
  snk s1 (.p(bi));
  snk s2 (.p(bi));
endmodule
