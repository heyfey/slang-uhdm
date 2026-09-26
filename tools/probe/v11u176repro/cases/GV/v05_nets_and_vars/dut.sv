// § genericPlainNamedView176
interface intf;
  wire [3:0] n;
  logic [3:0] v;
endinterface
module m (interface bus, input logic [3:0] x, output logic [3:0] y);
  assign bus.n = x;
  assign bus.v = bus.n;
  assign y = bus.v;
endmodule
module top (input logic [3:0] x, output logic [3:0] y);
  intf i ();
  m u (.bus(i), .x(x), .y(y));
endmodule
