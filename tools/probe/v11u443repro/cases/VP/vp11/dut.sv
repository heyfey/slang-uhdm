// § foreachPackedRefDeclTs443
module sub #(parameter W = 4); logic [W-1:0] v; int s; initial foreach (v[i]) s = s + i; endmodule
module top; sub #(2) a(); sub #(8) b(); endmodule
