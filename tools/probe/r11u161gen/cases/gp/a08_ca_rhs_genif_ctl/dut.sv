// r11u161 gen path CONTROL: cont-assign RHS paths inside a gen-if block (CFC, expected unchanged)
interface bus_if;
  logic [3:0] d;
endinterface
module child (bus_if sub, output logic [3:0] o, output logic [3:0] p);
  if (1) begin : g
    assign o = sub.d;
    assign p = {sub.d[1:0], sub.d[3:2]};
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o, output logic [3:0] p);
  bus_if b ();
  assign b.d = s;
  child c (.sub(b), .o(o), .p(p));
endmodule
