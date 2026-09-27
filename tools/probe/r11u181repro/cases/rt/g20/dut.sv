// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path in a concatenation and a replication
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [11:0] w; assign w = {$root.top.v, {2{$root.top.v}}}; endmodule
