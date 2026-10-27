// § foreachPackedRefDeclTs443
module top;
logic [7:0] a, b; int s;
initial foreach (b[i]) s = s + i;
endmodule
