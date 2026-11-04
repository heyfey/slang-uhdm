// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; bit [3:0] k; } op_s;
endpackage
module b_top;
  import p::*;
  op_s s;
endmodule
module a_top;
  import p::*;
  op_s s2;
endmodule
