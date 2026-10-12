// § delayParenInnerExprSpan292
`define my_delay(T) #(T);
module top;
  int t;
  int d [0:1];
  initial begin
    `my_delay(t)
    `my_delay(d[0])
    #(t) t = 1;
  end
endmodule
