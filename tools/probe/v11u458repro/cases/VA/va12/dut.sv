// § memberAliasFollowsMemberName458
package p;
  typedef logic [7:0] a_t;
  typedef union { a_t x; int y; } u_t;
endpackage
module hvl_top;
  import p::*;
  u_t s;
endmodule
module hdl_top;
  import p::*;
  u_t s2;
endmodule
