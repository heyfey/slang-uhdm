// § anonMemberTdLastWriter212 — a variable typed by the typedef whose continuous assignment writes a member select only
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  in_t z;
  assign v = d;
  assign z.b = d[0];
  assign z.a = d[4:1];
  assign o = v.q.b ^ z.b;
endmodule
