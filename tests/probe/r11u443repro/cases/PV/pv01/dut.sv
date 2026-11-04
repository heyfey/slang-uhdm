// § foreachPackedRefDeclTs443
module top;
bit [7:0] b; int s;
initial foreach (b[i]) s = s + b[i];
endmodule
