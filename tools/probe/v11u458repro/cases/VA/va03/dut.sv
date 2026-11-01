// § memberAliasFollowsMemberName458
package q;
  typedef logic [7:0] a_t;
endpackage
package p;
  import q::*;
  typedef struct { a_t addr; a_t data; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
