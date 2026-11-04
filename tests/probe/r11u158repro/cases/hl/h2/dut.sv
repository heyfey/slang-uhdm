// § arrQueryFoldAtBound158
module top();
  parameter [1:2] a = 1;
  parameter  high = $high(a);
  parameter  low = $low(a);
  parameter  left = $left(a);
  parameter  right = $right(a);
endmodule
