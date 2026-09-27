// § ifaceTwoPkgTdNameOrder186 (an interface with ports and a modport, two packages, enum typedefs, instanced in two modules)
package p1;
  typedef enum logic [1:0] { R, G, B } z_t;
endpackage
package p2;
  typedef enum logic { OFF, ON } a_t;
  typedef logic [7:0] m_t;
endpackage
interface bus_if(input logic clk);
  import p1::*;
  import p2::*;
  z_t c;
  a_t s;
  m_t d;
  modport mp(input c, s, d);
endinterface
module sink(bus_if.mp b); endmodule
module mid(input logic clk); bus_if bi(.clk(clk)); sink s(.b(bi)); endmodule
module top(input logic clk);
  bus_if b(.clk(clk));
  mid m(.clk(clk));
endmodule
