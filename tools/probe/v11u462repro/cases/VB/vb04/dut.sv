// § enumBaseInstFollowsEnum462
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
package b;
  import a::e_t;
  export a::e_t;
endpackage
module sub;
  import a::*;
  e_t v;
endmodule
module top;
  import b::*;
  sub u();
  e_t w;
endmodule
