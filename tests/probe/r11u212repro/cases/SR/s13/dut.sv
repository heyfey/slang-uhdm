// § anonMemberTdLastWriter212 — a variable typed by the typedef and continuously assigned, declared BEFORE the anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  in_t z;
  assign z = d[4:0];
  struct packed { in_t p; in_t q; } v;
  assign v = d;
  assign o = v.q.b ^ z.b;
endmodule
