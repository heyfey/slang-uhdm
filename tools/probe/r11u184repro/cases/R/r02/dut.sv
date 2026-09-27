// § rootLvalueSpanAtRoot184: a $root select target beside a $root read (copied from r11u181repro/cases/rt/s05, its residue R4)
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; initial begin w = $root.top.v; $root.top.v[1] = 1'b0; end endmodule
