// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; } op_s;
  op_s pv;
  class C;
    op_s cp;
  endclass
endpackage
module hdl_top;
  import p::*;
  C c;
endmodule
