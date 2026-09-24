// § anonMemberRefChainName134
// case m01: package union typedef with an anonymous struct member, imported and read by member
package p;
  typedef union packed {
    struct packed { logic [3:0] a; logic [3:0] b; } f;
    logic [7:0] raw;
  } u_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  u_t v;
  assign v.raw = i;
  assign o = v.f.b;
endmodule
