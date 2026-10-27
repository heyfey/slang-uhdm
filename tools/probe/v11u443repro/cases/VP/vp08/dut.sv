// § foreachPackedRefDeclTs443
module top;
var logic [7:0] v; int s;
initial foreach (v[i]) s = s + i;
endmodule
