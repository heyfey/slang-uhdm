// § firstOrderedPathSel161 — ordered connections of an instance array to interface paths
interface a_if;
  logic [1:0] d;
  logic [1:0] q;
endinterface
module leaf(input logic i, output logic y);
  assign y = ~i;
endmodule
module top(input logic [1:0] s, output logic [1:0] o);
  a_if b();
  assign b.d = s;
  leaf u [1:0] (b.d, b.q);
  assign o = b.q;
endmodule
