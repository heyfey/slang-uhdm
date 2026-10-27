// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
initial begin foreach (v[i]) s = s + i; foreach (v[j]) s = s - j; end
endmodule
