// § rootPathFullNameByChain181 § rootPathElemOwnName181 (v11u181 break: $root reads of a struct member and a nested instance, two instances of a sub)
typedef struct packed { logic [3:0] f; logic g; } s_t;
module sub(input logic i, output logic o);
  logic [3:0] q;
  always_comb q = $root.top.s.f + $root.top.u1.q;
  assign o = i & $root.top.s.g;
endmodule
module top;
  s_t s;
  logic a, b, c;
  sub u1(.i(a), .o(b));
  sub u2(.i(b), .o(c));
endmodule
