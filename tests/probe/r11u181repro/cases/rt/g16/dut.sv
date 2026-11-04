// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path spelled through a macro
`define R $root.top.v
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; initial w = `R; endmodule
