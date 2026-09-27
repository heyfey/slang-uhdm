// § rootLvalueSpanAtRoot184: a $root path as a whole lvalue (copied from r11u181repro/cases/rt/g05, its residue R4)
module top; logic [3:0] v; sub u(); endmodule
module sub; initial $root.top.v = 4'd1; endmodule
