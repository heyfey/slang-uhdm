// § foreachPackedRefDeclTs443
module sub; logic [7:0] v; int s; initial foreach (v[i]) s = s + i; endmodule
module top; sub u1(); sub u2(); endmodule
