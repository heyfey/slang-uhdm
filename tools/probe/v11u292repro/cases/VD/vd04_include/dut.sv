// § delayParenInnerExprSpan292
`include "inc.svh"
module top;
  parameter int P = 2;
  int x;
  initial begin
    `IDLY( P ) x = 1;
    `IDLY(/*a*/P/*b*/) x = 2;
    # /* gap */ ( P ) x = 3;
  end
  always #( P ) x = x + 1;
  task automatic tk(); #(  P  ) x = 0; endtask
endmodule
