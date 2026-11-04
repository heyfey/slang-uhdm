// § foreachPackedRefDeclTs443
module top;
logic signed [7:0] v; int s;
always @* foreach (v[i]) s = s + v[i];
endmodule
