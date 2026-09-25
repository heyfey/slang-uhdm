// § arrQueryFoldAtBound158
module top();
  parameter [2:1] a = 10;
  parameter int high = $high(a);
  localparam logic [3:0] low = $low(a);
endmodule
