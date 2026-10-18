// § kwArrayMethodIsCallElem401
module top;
  int q[$]; int r[$];
  initial begin r = q.unique(); r = q.unique with (item % 2); end
endmodule
