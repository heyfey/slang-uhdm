// § foreachPackedRefDeclTs443
module top;
string str; int s;
initial begin str = "abc"; foreach (str[i]) s = s + i; end
endmodule
