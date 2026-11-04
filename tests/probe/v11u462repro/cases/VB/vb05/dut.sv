// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
package b;
  import a::*;
  class K;
    e_t f;
  endclass
endpackage
module top;
  import b::*;
  K k;
endmodule
