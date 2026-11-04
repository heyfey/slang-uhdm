// § firstOrderedPathSel161 — an ordered list whose first position is empty: the path is the second actual
interface c_if;
  logic [3:0] d;
  logic [3:0] q;
endinterface
module leaf(input logic [3:0] i, output logic [3:0] y);
  assign y = 4'd5;
endmodule
module top(output logic [3:0] o);
  c_if b();
  leaf u0 ( , b.q);
  assign o = b.q;
endmodule
