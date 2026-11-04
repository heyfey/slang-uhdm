// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
initial foreach (v[i]) foreach (v[j]) s = s + i + j;
endmodule
