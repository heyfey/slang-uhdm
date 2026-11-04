// § loopVarParamReadUnbound445
module top;
parameter int item = 2;
int q[$]; int s;
if (1) begin : g initial s = q.sum() with (item * 2); end
endmodule
