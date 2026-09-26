// § firstOrderedPathSel161 — the first ordered actual is a concatenation of paths (not a path: the law abstains)
interface c_if;
  logic [1:0] d;
  logic [1:0] e;
  logic [3:0] q;
endinterface
module leaf(input logic [3:0] i, output logic [3:0] y);
  assign y = ~i;
endmodule
module top(input logic [3:0] s, output logic [3:0] o);
  c_if b();
  assign {b.d, b.e} = s;
  leaf u0 ({b.d, b.e}, b.q);
  assign o = b.q;
endmodule
