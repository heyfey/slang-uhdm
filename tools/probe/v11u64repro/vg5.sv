// v11u64 verifier grid 5 — the CAST face (pass 55's fence) and a symbolic
// member reached through a cast, plus a cast with a `default:` fill.
module vk1 #(parameter int V = 3) (input logic [63:0] pa, output logic o);
  typedef struct packed { logic [7:0] m0; logic [V-1:0] m1; } t;
  t s, s2;
  assign s  = t'('{m0: pa, m1: '0});
  assign s2 = t'('{m0: pa, default: '0});
  assign o = ^{s, s2};
endmodule
module vtb5;
  logic [63:0] pa; logic o;
  vk1 k (.pa(pa), .o(o));
endmodule
