// § anonMemberRefChainName134
// case m04: module-local union typedef with an anonymous struct member, read through the member
module top(input logic [7:0] i, output logic [3:0] o);
  typedef union packed {
    struct packed { logic [3:0] a; logic [3:0] b; } f;
    logic [7:0] raw;
  } u_t;
  u_t v;
  assign v.raw = i;
  assign o = v.f.a;
endmodule
