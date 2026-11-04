// § anonMemberTdLastWriter212 — an interface named zi and a module named dut each writing the typedef in an anonymous struct (definition kinds in one name order?)
typedef struct packed { logic [3:0] a; logic b; } in_t;
interface zi;
  struct packed { in_t izi; } v;
endinterface
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t mdut; } w;
  zi b();
  assign w = d[4:0];
  assign b.v = d[9:5];
  assign o = w.mdut.b ^ b.v.izi.b;
endmodule
