// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
always_comb begin s = 0; foreach (v[i]) s = s + v[i]; end
endmodule
