// § foreachPackedRefDeclTs443
module top;
string str; int s;
initial foreach (str[i]) s = s + i;
endmodule
