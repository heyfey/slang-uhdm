// § delayParenInnerExprSpan292
module top(input logic clk, input logic d);
  parameter int SK = 2;
  logic q;
  clocking cb @(posedge clk);
    default input #( 1 ) output #( SK );
    input d;
    output q;
  endclocking
  initial begin
    @(cb);
    #( SK ) cb.q <= 1'b1;
    q <= #( 1 ) 1'b0;
  end
endmodule
