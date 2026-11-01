// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; } op_s;
endpackage
interface zif;
  import p::*;
  op_s s;
endinterface
module hdl_top;
  import p::*;
  op_s s2;
  zif u();
endmodule
