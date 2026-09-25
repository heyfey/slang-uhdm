// r11u161 port face (R5): ordered connections, OUTPUT formal first, input second
interface bus_if;
  logic [3:0] d;
  logic [3:0] q;
endinterface
module leaf (output logic [3:0] y, input logic [3:0] i);
  assign y = ~i;
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  leaf u0 (b.q, b.d);
  assign o = b.q;
endmodule
