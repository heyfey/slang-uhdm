// § foreachPackedRefDeclTs443
module top;
logic [1:0][3:0][7:0] v; int s;
initial foreach (v[i, j, k]) s = s + i + j + k;
endmodule
