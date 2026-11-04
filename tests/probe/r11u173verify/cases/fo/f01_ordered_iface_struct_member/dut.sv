// § firstOrderedPathSel161 — ordered list of three: the first actual a struct member of an interface variable
typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
interface s_if;
  s_t s;
  logic [3:0] q;
endinterface
module leaf(input logic [3:0] i, input logic [3:0] j, output logic [3:0] y);
  assign y = i ^ j;
endmodule
module top(input logic [7:0] a, output logic [3:0] o);
  s_if b();
  assign b.s = a;
  leaf u0 (b.s.f, b.s.g, b.q);
  assign o = b.q;
endmodule
