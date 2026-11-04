// § intraAsgEventSpanInner401v
module top;
  logic clk; int a, b;
  task t; a = @(posedge clk or negedge clk) b; a <= repeat (b + 1) @(clk) b; endtask
  initial t();
endmodule
