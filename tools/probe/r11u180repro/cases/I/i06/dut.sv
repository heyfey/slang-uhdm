// § ifaceWildcardTdNameOrder180
package p;
  typedef logic [3:0] w_t;
  typedef logic [1:0] b_t;
endpackage
interface bus_if;
  import p::*;
  w_t w; b_t b;
endinterface
module top (output logic [3:0] o);
  bus_if b();
  assign o = b.w;
endmodule
