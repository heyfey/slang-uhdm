// r11u161 gen path: a declaration range bound reading an interface-port parameter inside a gen block (SEL)
interface bus_if #(parameter int W = 4);
  logic [3:0] d;
endinterface
module child (bus_if sub, output logic [3:0] o);
  if (1) begin : g
    logic [sub.W-1:0] t;
    assign t = sub.d;
    assign o = t;
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  child c (.sub(b), .o(o));
endmodule
