// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; } op_s;
endpackage
module hvl;
  import p::*;
  op_s s;
endmodule
module hdl;
  import p::*;
  op_s s2;
endmodule
module top;
  hdl u1();
  hvl u2();
endmodule
