// § foreachPackedRefDeclTs443
module top;
logic [7:0] v = 8'h5; int s;
initial foreach (v[i]) s = s + v[i];
endmodule
