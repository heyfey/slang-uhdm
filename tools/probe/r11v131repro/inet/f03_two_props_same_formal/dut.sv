// § implicitNetMintNoFile131
module top (input logic clk, input logic a, input logic b);
  property p1(req); @(posedge clk) req; endproperty
  property p2(req, ack); @(posedge clk) req |=> ack; endproperty
  assert property (p1(a));
  assert property (p2(a, b));
endmodule
