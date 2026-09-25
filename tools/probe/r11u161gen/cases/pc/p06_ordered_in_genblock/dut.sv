// r11u161 port face (R5): ordered input connection to an interface member inside a generate block
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
  if (1) begin : g
    leaf u0 (b.d, b.q);
  end
  assign o = b.q;
endmodule
