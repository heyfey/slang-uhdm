// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path index inside a $root lvalue
module top; logic [3:0] v; int i; sub u(); endmodule
module sub; initial $root.top.v[$root.top.i] = 1'b1; endmodule
