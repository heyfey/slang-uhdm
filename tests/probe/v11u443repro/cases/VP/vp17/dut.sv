// § foreachPackedRefDeclTs443
module top;
logic [7:0] v [2]; int s;
initial foreach (v[i, j]) s = s + i + j;
endmodule
