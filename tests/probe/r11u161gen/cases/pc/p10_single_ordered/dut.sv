// r11u161 port face (R5): a SINGLE ordered connection to a member path
interface bus_if;
  logic [3:0] d;
endinterface
module leaf (input logic [3:0] i);
endmodule
module top (input logic [3:0] s);
  bus_if b ();
  assign b.d = s;
  leaf u0 (b.d);
endmodule
