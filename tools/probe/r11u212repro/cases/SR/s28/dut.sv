// § anonMemberTdLastWriter212 — the anonymous struct declared in an interface instantiated by the module
typedef struct packed { logic [3:0] a; logic b; } in_t;
interface bi;
  struct packed { in_t ip; in_t iq; } v;
endinterface
module dut(input logic [9:0] d, output logic o);
  bi b();
  assign b.v = d;
  assign o = b.v.iq.b;
endmodule
