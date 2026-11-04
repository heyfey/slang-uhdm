// § seqAndOrLogOp420
module top;
  logic clk, a, b, c, d, e;
  property p;
    @(posedge clk) a |-> ((b ##1 c) and (d ##1 e));
  endproperty
  assert property (p);
endmodule
