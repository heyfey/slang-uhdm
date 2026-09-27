// § ifaceWildcardTdNameOrder180 (verifier: upper and lower case typedef names)
package p;
  typedef logic [3:0] zeta_t;
  typedef logic [2:0] Beta_t;
  typedef logic [1:0] alpha_t;
endpackage
interface bus_if;
  import p::*;
  zeta_t x; Beta_t y; alpha_t z;
endinterface
module top;
  bus_if b();
endmodule
