// § rootPathElemOwnName181 § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path as a port actual
module top; logic [3:0] v; sub u(); endmodule
module sub3(input logic [3:0] a); endmodule
module sub; sub3 u3(.a($root.top.v)); endmodule
