// § anonMemberTdLastWriter212 — a function argument typed by the typedef beside the anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  function automatic logic f(in_t x); return x.b; endfunction
  assign v = d;
  assign o = f(v.q);
endmodule
