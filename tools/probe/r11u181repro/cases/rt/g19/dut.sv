// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path in a module top itself, under a ternary
module top; logic [3:0] v, x; logic s; assign x = s ? $root.top.v : 4'd0; endmodule
