// § anonMemberTdLastWriter212 — verifier: the anonymous struct variable in a module and a second anonymous struct typing a localparam after it
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o);
  struct packed { in_t mv; } w;
  localparam struct packed { in_t mp; } LP = 5'b10101;
  always_comb w = d;
  assign o = w.mv.b ^ LP.mp.b;
endmodule
