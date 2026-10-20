// § seqAndOrLogOp420
interface ifc(input clk);
  logic a, b, c, d;
  sequence s;
    @(posedge clk) (a ##1 b) or (c ##1 d);
  endsequence
  assert property (s);
endinterface
module top;
  logic clk;
  ifc u(clk);
endmodule
