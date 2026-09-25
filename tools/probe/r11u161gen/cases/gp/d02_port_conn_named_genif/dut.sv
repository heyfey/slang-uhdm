// r11u161 gen path: named port actuals inside a gen-if block (CFC)
interface bus_if;
  logic [3:0] d;
  logic [3:0] q;
endinterface
module leaf (input logic [3:0] i, output logic [3:0] y);
  assign y = ~i;
endmodule
module child (bus_if sub);
  if (1) begin : g
    leaf u0 (.i(sub.d), .y(sub.q));
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  assign o = b.q;
  child c (.sub(b));
endmodule
