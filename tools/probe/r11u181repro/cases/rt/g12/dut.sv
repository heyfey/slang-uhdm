// § rootPathFullNameByChain181 — a $root bit-select read
module top; logic [3:0] v; sub u(); endmodule
module sub; logic w; initial w = $root.top.v[1]; endmodule
