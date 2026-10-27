// § foreachPackedRefDeclTs443
module top(o);
output [3:0] o; int s;
initial foreach (o[i]) s = s + i;
endmodule
