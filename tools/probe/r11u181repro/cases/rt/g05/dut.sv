// § rootPathFullNameByChain181 — a $root path as a whole lvalue (control)
module top; logic [3:0] v; sub u(); endmodule
module sub; initial $root.top.v = 4'd1; endmodule
