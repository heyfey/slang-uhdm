// r11u161 gen path: cont-assign LHS inside a gen-if block, interface-port member (SEL)
interface bus_if;
  logic [3:0] sel;
  logic [3:0] rsp;
endinterface
module child (bus_if sub);
  if (1) begin : g
    assign sub.rsp = sub.sel;
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.sel = s;
  assign o = b.rsp;
  child c (.sub(b));
endmodule
