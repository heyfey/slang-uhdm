// § anonMemberRefChainName134
// case m05: a struct typedef with an anonymous struct member, in a sub-module instantiated twice
module sub(input logic [5:0] i, output logic [1:0] o);
  typedef struct packed {
    struct packed { logic [1:0] p; logic [1:0] q; } in;
    logic [1:0] r;
  } s_t;
  s_t v;
  assign v = i;
  assign o = v.in.q;
endmodule
module top(input logic [5:0] i, output logic [1:0] o1, output logic [1:0] o2);
  sub u1(.i(i), .o(o1));
  sub u2(.i(i), .o(o2));
endmodule
