// r11u161 gen path: cont-assign LHS with a constant bit-select on the leaf inside a gen-if block
interface bus_if;
  logic [1:0] q;
endinterface
module child (bus_if sub, input logic a);
  if (1) begin : g
    assign sub.q[0] = a;
    assign sub.q[1] = ~a;
  end
endmodule
module top (input logic s, output logic [1:0] o);
  bus_if b ();
  assign o = b.q;
  child c (.sub(b), .a(s));
endmodule
