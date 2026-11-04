// § genericPlainNamedView176
interface intf #(parameter W = 2);
  logic [W-1:0] data;
endinterface
module m (interface bus, input logic [5:0] x);
  assign bus.data = x;
endmodule
module top (input logic [5:0] x, output logic [5:0] y);
  intf #(.W(6)) i ();
  m u (.bus(i), .x(x));
  assign y = i.data;
endmodule
