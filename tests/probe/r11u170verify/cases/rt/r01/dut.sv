// § rootPathOwnNames157
module top; logic [3:0] v; logic [3:0] x; sub u(); sub2 u2(); endmodule
module sub; wire [3:0] w; assign w = $root.top.v & $root.top.u2.y; endmodule
module sub2; logic [3:0] y; endmodule
