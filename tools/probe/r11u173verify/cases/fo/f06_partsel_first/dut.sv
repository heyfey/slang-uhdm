// § firstOrderedPathSel161 — the first ordered actual is a part select of an interface member path
interface c_if;
  logic [7:0] d;
  logic [3:0] q;
endinterface
module leaf(input logic [3:0] i, output logic [3:0] y);
  assign y = ~i;
endmodule
module top(input logic [7:0] s, output logic [3:0] o);
  c_if b();
  assign b.d = s;
  leaf u0 (b.d[3:0], b.q);
  assign o = b.q;
endmodule
