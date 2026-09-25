// § arrQueryFoldAtBound158
module top();
  parameter W = 4;
  parameter [W-1:0] a = 0;
  parameter  high = $high(a);
  parameter  low = $low(a);
endmodule
