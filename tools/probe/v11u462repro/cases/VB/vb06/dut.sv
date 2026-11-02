// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
endpackage
module top;
  import c::*;
  logic x;
endmodule
