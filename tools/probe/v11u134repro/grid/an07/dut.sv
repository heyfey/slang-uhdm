// § anonMemberRefChainName134
module top(input logic c, output logic o);
  struct packed { struct packed { logic a; logic [1:0] b; } in; logic d; } v;
  always_comb begin v = '0; v.in.a = c; end
  assign o = v.in.a ^ v.d;
endmodule
