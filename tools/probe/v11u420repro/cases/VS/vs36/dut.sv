// § clockedSeqEventSpanBare420
interface ifc; logic clk1, x; endinterface
module top(input logic clk, a);
  ifc dif();
  property p; @(posedge clk) a ##1 @(posedge dif.clk1) dif.x; endproperty
  assert property (p);
endmodule
