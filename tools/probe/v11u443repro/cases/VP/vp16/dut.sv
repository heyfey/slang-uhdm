// § foreachPackedRefDeclTs443
module top;
wire [3:0] w; logic [3:0] s;
always_comb foreach (w[i]) s[i] = w[i];
endmodule
