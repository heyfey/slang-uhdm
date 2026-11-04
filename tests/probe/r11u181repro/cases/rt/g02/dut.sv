// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path as a system task argument
module top; logic [3:0] v; sub u(); endmodule
module sub; initial $display("%d", $root.top.v); endmodule
