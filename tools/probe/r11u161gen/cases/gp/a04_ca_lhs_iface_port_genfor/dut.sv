// r11u161 gen path: cont-assign LHS inside a gen-for block, interface-port member (SEL), index by genvar
interface bus_if;
  logic [3:0] sel;
  logic [3:0] rsp;
endinterface
module child (bus_if sub);
  for (genvar i = 0; i < 4; i++) begin : g
    assign sub.rsp[i] = sub.sel[i];
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.sel = s;
  assign o = b.rsp;
  child c (.sub(b));
endmodule
