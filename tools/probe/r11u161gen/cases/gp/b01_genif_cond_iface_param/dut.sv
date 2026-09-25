// r11u161 gen path: gen-if condition reading an interface-port parameter (SEL)
interface bus_if #(parameter int W = 2);
  logic [3:0] d;
endinterface
module child (bus_if sub, output logic [3:0] o);
  if (sub.W == 2) begin : g
    assign o = sub.d;
  end else begin : h
    assign o = '0;
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if #(.W(2)) b ();
  assign b.d = s;
  child c (.sub(b), .o(o));
endmodule
