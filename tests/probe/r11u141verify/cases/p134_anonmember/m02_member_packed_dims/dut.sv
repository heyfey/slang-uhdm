// § anonMemberRefChainName134
// case m02: an anonymous struct member with packed dimensions
module top(input logic [9:0] i, output logic [1:0] o);
  typedef struct packed {
    struct packed { logic a; logic [1:0] b; } [1:0] pr;
    logic [3:0] tail;
  } s_t;
  s_t v;
  assign v = i;
  assign o = v.pr[1].b;
endmodule
