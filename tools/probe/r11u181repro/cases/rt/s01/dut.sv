// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — the $root path baseline copied from tools/probe/r11u170verify cases/rt/r01 (its law there: pass 157/167)
module top; logic [3:0] v; logic [3:0] x; sub u(); sub2 u2(); endmodule
module sub; wire [3:0] w; assign w = $root.top.v & $root.top.u2.y; endmodule
module sub2; logic [3:0] y; endmodule
