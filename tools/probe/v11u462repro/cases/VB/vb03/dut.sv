// § enumBaseInstFollowsEnum462
package a;
  typedef logic [2:0] b_t;
  typedef enum b_t {N0, N1, N2} e_t;
endpackage
package b;
  import a::*;
endpackage
interface ifc;
  import a::*;
  e_t v;
endinterface
module top;
  import b::*;
  ifc u();
endmodule
