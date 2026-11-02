// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
interface ifc;
  import a::*;
  e_t v;
endinterface
module top;
  import a::*;
  ifc u();
endmodule
