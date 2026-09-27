// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path in an if condition and a case expression
module top; logic [3:0] v; sub u(); endmodule
module sub; logic w; initial begin if ($root.top.v == 0) w = 1; case ($root.top.v) 1: w = 0; default: w = 1; endcase end endmodule
