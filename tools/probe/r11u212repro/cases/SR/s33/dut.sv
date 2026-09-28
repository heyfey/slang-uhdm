// § anonMemberTdLastWriter212 — an interface named ai and a module named dut each writing the typedef in an anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
interface ai;
  struct packed { in_t iai; } v;
endinterface
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t mdut; } w;
  ai b();
  assign w = d[4:0];
  assign b.v = d[9:5];
  assign o = w.mdut.b ^ b.v.iai.b;
endmodule
