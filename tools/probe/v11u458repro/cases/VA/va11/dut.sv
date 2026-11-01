// § memberAliasFollowsMemberName458
package p;
  typedef bit [1:0] b2_t;
  typedef enum b2_t {R, W} k_e;
  typedef struct { k_e kind; b2_t raw; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
