// § memberAliasFollowsMemberName458
package p;
  typedef logic signed [7:0] a_t;
  typedef struct { a_t addr; a_t arr [2]; bit b; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
