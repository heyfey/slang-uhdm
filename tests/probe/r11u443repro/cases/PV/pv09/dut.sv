// § foreachPackedRefDeclTs443
module top;
logic [7:0] v;
always_comb foreach (v[i]) v[i] = 1'b0;
endmodule
