// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit [3:0] y; } s_t;
endpackage
interface ifc;
  import p::*;
  s_t v;
endinterface
module top;
  ifc i();
endmodule
