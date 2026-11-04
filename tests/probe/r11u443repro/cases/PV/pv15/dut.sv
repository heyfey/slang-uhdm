// § foreachPackedRefDeclTs443
module top;
wire [3:0] w = 4'h5; int s;
initial foreach (w[i]) s = s + w[i];
endmodule
