// § foreachPackedRefDeclTs443
module top;
reg [7:0] r; integer s;
initial begin s = 0; foreach (r[i]) s = s + r[i]; end
endmodule
