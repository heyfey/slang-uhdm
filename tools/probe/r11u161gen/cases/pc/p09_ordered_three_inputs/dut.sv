// r11u161 port face (R5): three ordered input connections to member paths
interface bus_if;
  logic [3:0] d;
  logic [3:0] e;
  logic [3:0] f;
endinterface
module leaf (input logic [3:0] i, input logic [3:0] j, input logic [3:0] k);
endmodule
module top (input logic [3:0] s);
  bus_if b ();
  assign b.d = s;
  assign b.e = ~s;
  assign b.f = s;
  leaf u0 (b.d, b.e, b.f);
endmodule
