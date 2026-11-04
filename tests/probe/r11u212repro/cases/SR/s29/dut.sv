// § anonMemberTdLastWriter212 — control: a logic vector typedef written twice in an anonymous struct
typedef logic [3:0] n_t;
module dut(input logic [7:0] d, output logic o);
  struct packed { n_t p; n_t q; } v;
  assign v = d;
  assign o = v.q[0];
endmodule
