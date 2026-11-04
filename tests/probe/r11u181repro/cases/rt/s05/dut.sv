// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — the $root path baseline copied from tools/probe/r11v158repro cases/hp/r09 (its law there: pass 157/167)
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; initial begin w = $root.top.v; $root.top.v[1] = 1'b0; end endmodule
