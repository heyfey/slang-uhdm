// § classTdStructMemberPkgPath146
package p;
class c;
  typedef struct { int unsigned n; } acc_t;
  acc_t a;
endclass
endpackage
module top import p::*; (output int o);
  c h;
  assign o = 0;
endmodule
