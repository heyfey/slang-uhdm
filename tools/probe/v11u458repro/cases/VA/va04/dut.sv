// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef a_t b_t;
  typedef struct { b_t addr; a_t d; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
