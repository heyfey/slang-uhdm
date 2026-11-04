// § rootPathElemOwnName181 § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root read in a generate-if scope
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; if (1) begin : g assign w = $root.top.v; end endmodule
