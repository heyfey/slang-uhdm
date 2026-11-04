// § pkgArrTdListing250
package p;
  typedef int i_t[int];
  typedef logic [1:0] u_t[int unsigned];
  typedef byte l_t[longint];
endpackage
module top;
  import p::*;
  i_t i; u_t u; l_t l;
endmodule
