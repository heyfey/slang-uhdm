// § foreachPackedRefDeclTs443
module top;
int x; int s;
initial foreach (x[i]) s = s + i;
endmodule
