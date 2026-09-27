// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a deeper $root path in a continuous assignment
module top; sub u(); sub2 u2(); endmodule
module sub2; logic [3:0] y; endmodule
module sub; wire [3:0] w; assign w = $root.top.u2.y; endmodule
