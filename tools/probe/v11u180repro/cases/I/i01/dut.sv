// § ifaceWildcardTdNameOrder180 (verifier: two wildcard imports whose typedef names interleave)
package p1;
  typedef logic [3:0] c_t;
  typedef logic [2:0] a_t;
endpackage
package p2;
  typedef logic [1:0] b_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  a_t x; b_t y; c_t z;
endinterface
module top;
  bus_if b();
endmodule
