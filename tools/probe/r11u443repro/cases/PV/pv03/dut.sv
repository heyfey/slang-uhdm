// § foreachPackedRefDeclTs443
module top;
logic [3:0][1:0] pv; int s;
initial foreach (pv[i, j]) s = s + pv[i][j];
endmodule
