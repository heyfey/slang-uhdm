// r11u161 port face CONTROL (R5): named connections to member paths stay CFC
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
  leaf u0 (.i(b.d), .y(b.q));
  assign o = b.q;
endmodule
