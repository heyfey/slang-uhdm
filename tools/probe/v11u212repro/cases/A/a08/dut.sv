// § anonMemberTdLastWriter212 — verifier: a static task local anonymous struct written after the module variable
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o);
  struct packed { in_t mm; } w;
  always_comb w = d;
  assign o = w.mm.b;
  task t();
    struct packed { in_t mt; } tv;
    tv = d;
  endtask
endmodule
