// § foreachPackedRefDeclTs443
module top(input logic [3:0] in);
int s;
always_comb begin s = 0; foreach (in[i]) s = s + in[i]; end
endmodule
