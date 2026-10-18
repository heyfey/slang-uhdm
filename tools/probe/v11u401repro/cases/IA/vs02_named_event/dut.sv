// § intraAsgEventSpanInner401v
module top;
  event e; int n; logic a, b, clk;
  initial begin a = @(e) b; a <= repeat (n) @(posedge clk) b; a <= repeat ((2)) @(posedge clk) b; end
endmodule
