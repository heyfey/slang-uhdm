// r11u161 gen path: cont-assign LHS with a part-select on the leaf inside a gen-if block
interface bus_if;
  logic [7:0] q;
endinterface
module child (bus_if sub, input logic [3:0] a);
  if (1) begin : g
    assign sub.q[3:0] = a;
    assign sub.q[7:4] = ~a;
  end
endmodule
module top (input logic [3:0] s, output logic [7:0] o);
  bus_if b ();
  assign o = b.q;
  child c (.sub(b), .a(s));
endmodule
