// § anonMemberTdLastWriter212 — decline: an automatic function-local anonymous struct writing the typedef, beside the module's
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  function automatic logic f(logic [4:0] x);
    struct packed { in_t fz; } t;
    t = x;
    return t.fz.b;
  endfunction
  assign v = d;
  assign o = v.q.b ^ f(d[4:0]);
endmodule
