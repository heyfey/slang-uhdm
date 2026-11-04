// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
always @* begin : blk foreach (v[i]) s = s + i; end
endmodule
