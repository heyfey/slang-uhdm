// § delayParenInnerExprSpan292
interface ifc(input logic clk);
  logic v;
  initial begin #( 3 ) v = 1; end
endinterface
module top;
  parameter int HALF = 5;
  logic clk = 0;
  logic d;
  always #(HALF) clk = ~clk;
  always #( HALF ) d = ~clk;
  initial begin
    #( HALF ) begin d = 0; end
    #( HALF ) @(posedge clk);
    #( HALF ) $display("x");
    #( HALF*2 ) wait (d);
    forever #( HALF ) d = !d;
  end
  ifc i(.clk(clk));
  wire w;
  assign #( 2 ) w = d;
  and #( 1 ) g1(w2, d, clk);
endmodule
