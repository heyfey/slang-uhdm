// § delayParenInnerExprSpan292
module top(input logic clk);
  parameter time P = 2;
  int x;
  initial begin
    #((P)) x = 1;
    #(1:2:3) x = 2;
    #( 1 : 2 : 3 ) x = 3;
    #(1ns) x = 4;
    #( 5 ) x = 5;
    #(P) ;
    repeat (2) #( P ) x = 6;
    @(posedge clk) #( P*2 ) x = 7;
    fork #( P ) x = 8; join
    x = #( P ) 9;
    x <= #( P ) 10;
    #(
      P) x = 11;
    #(P // tail
    ) x = 12;
  end
endmodule
