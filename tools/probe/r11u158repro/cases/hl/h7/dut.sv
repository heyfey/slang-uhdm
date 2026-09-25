// § arrQueryFoldAtBound158
module sub #(parameter [3:0] A = 0, parameter H = $high(A))();
endmodule
module top();
  sub #(.A(3)) u();
endmodule
