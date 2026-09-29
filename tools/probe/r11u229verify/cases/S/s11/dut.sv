// § strLitPpEscIdShift224 (a $display with the literal between other arguments)
module top(input int k);
  initial $display("%s %0d", "a\nb` c", k);
endmodule
