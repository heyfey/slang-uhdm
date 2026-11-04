// § genericPlainNamedView176
interface intf;
  logic [3:0] a;
  logic [3:0] q;
endinterface
module m (interface bus, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bus.q <= bus.a;
  assign bus.a = x;
endmodule
module top (input logic clk, input logic [3:0] x, output logic [3:0] y);
  intf i ();
  m u (.bus(i), .clk(clk), .x(x));
  assign y = i.q;
endmodule
