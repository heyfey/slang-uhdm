// § implicitNetMintNoFile131
module top (input logic clk, input logic a, input logic req);
  property p1(req);
    @(posedge clk) req;
  endproperty
  assert property (p1(a));
endmodule
