// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
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
