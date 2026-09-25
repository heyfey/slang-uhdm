// r11u161 port face (R5): ordered connections to hierarchical paths, input and output
interface bus_if;
  logic [3:0] d;
  logic [3:0] q;
endinterface
module leaf (input logic [3:0] i, output logic [3:0] y);
  assign y = ~i;
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  leaf u0 (b.d, b.q);
  assign o = b.q;
endmodule
