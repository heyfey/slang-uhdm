// § arrQueryFoldAtBound158
module top();
  parameter [2:1] a = 10;
  parameter  high = $high(a);
  parameter  low = $low(a);
  parameter  left = $left(a);
  parameter  right = $right(a);
endmodule
