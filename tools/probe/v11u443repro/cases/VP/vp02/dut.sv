// § foreachPackedRefDeclTs443
module top;
integer x; int s;
initial foreach (x[i]) s = s + i;
endmodule
