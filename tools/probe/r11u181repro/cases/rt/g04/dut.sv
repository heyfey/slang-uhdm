// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path as an operand
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; initial w = $root.top.v + 4'd1; endmodule
