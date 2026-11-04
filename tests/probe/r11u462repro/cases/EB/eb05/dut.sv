// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
package b;
  import a::*;
endpackage
module top;
  import b::*;
  sub s();
endmodule
module sub;
  import a::*;
  e_t v;
endmodule
