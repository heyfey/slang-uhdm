// § genericPlainNamedView176
interface intf;
  logic [3:0] a;
  logic [3:0] b;
endinterface
module prod (interface bus, input logic [3:0] x);
  assign bus.a = x;
endmodule
module cons (interface bus, output logic [3:0] y);
  assign y = bus.a;
endmodule
module top (input logic [3:0] x, output logic [3:0] y);
  intf i ();
  prod p (.bus(i), .x(x));
  cons c (.bus(i), .y(y));
endmodule
