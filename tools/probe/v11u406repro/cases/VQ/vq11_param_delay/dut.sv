// § seqConcatNestsRight406
module top #(parameter D = 2) (input logic clk, input logic a, input logic b, input logic c);
  sequence s;
    a ##D b ##1 c;
  endsequence
  assert property (@(posedge clk) s);
endmodule
