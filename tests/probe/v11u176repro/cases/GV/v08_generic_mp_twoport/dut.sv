// § genericMpConnLowConnAtDecl176
interface intf;
  logic [3:0] a;
  modport src (output a);
  modport dst (input a);
endinterface
module m (interface s, interface d, input logic [3:0] x, output logic [3:0] y);
  assign s.a = x;
  assign y = d.a;
endmodule
module top (input logic [3:0] x, output logic [3:0] y);
  intf i ();
  m u (.s(i.src), .d(i.dst), .x(x), .y(y));
endmodule
