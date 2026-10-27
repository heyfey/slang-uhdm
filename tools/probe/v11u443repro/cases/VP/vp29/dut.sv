// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
initial foreach (v[i]) begin int t; t = i; s = s + t; end
endmodule
