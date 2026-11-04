// § arrQueryFoldAtBound158
module sub();
  parameter [6:2] a = 0;
  parameter high = $high(a);
endmodule
module top(); sub u(); sub #(.a(1)) v(); endmodule
