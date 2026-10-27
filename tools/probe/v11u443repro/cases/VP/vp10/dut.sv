// § foreachPackedRefDeclTs443
module top;
bit [0:7] v; int s;
initial foreach (v[i]) s = s + i;
endmodule
