// § foreachPackedRefDeclTs443
module top;
integer k; int s;
initial begin k = 5; foreach (k[i]) s = s + k[i]; end
endmodule
