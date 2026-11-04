// § anonMemberTdLastWriter212 — an enum typedef written as a member of an anonymous struct, twice
typedef enum logic [1:0] { A, B, C } e_t;
module dut(input logic [3:0] d, output logic o);
  struct packed { e_t p; e_t q; } v;
  assign v = d;
  assign o = (v.q == B);
endmodule
