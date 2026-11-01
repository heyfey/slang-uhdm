// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; } op_s;
endpackage
module hvl_top;
  import p::*;
  for (genvar i = 0; i < 2; i++) begin : g
    op_s s;
  end
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
