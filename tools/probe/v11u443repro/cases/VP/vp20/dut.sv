// § foreachPackedRefDeclTs443
module top;
reg [7:0] r; integer s;
initial foreach (r[i]) s = s + i;
endmodule
