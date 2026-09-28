// § anonMemberTdLastWriter212 — the anonymous struct declared in a generate block
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  if (1) begin : g
    struct packed { in_t p; in_t q; } v;
    assign v = d;
  end
  assign o = g.v.q.b;
endmodule
