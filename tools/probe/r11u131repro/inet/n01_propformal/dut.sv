// § implicitNetMintNoFile131
module top(input logic clk, input logic a, input logic b);
  property p1(req, ack);
    @(posedge clk) req |-> ack;
  endproperty
  assert property (p1(a, b));
endmodule
