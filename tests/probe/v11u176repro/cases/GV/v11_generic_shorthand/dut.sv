// § genericPlainNamedView176
interface intf;
  logic [3:0] a;
endinterface
module m (interface bus, input logic [3:0] x);
  assign bus.a = x;
endmodule
module top (input logic [3:0] x, output logic [3:0] y);
  intf bus ();
  m u (.bus, .x);
  assign y = bus.a;
endmodule
