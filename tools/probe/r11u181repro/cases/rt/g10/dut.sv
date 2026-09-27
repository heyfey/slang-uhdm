// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root read in a nonblocking assignment
module top; logic [3:0] v; logic clk; sub u(); endmodule
module sub; logic [3:0] w; always @(posedge $root.top.clk) w <= $root.top.v; endmodule
