// § firstOrderedPathSel161 — ordered parameter and ordered ports to interface paths inside a gen-if block
interface g_if;
  logic [3:0] d;
  logic [3:0] q;
endinterface
module leaf #(parameter int N = 1) (input logic [3:0] i, output logic [3:0] y);
  assign y = i + N;
endmodule
module top(input logic [3:0] s, output logic [3:0] o);
  g_if b();
  assign b.d = s;
  if (1) begin : g
    leaf #(2) u0 (b.d, b.q);
  end
  assign o = b.q;
endmodule
