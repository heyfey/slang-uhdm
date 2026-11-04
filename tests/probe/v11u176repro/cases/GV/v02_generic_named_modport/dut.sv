// § genericMpConnLowConnAtDecl176
interface intf;
  logic [3:0] a;
  logic [3:0] b;
  modport mp (output a, input b);
endinterface
module m (interface bus, input logic [3:0] x, output logic [3:0] y);
  assign bus.a = x;
  assign y = bus.b;
endmodule
module top (input logic [3:0] x, output logic [3:0] y);
  intf i ();
  assign i.b = i.a ^ 4'd5;
  m u (.bus(i.mp), .x(x), .y(y));
endmodule
