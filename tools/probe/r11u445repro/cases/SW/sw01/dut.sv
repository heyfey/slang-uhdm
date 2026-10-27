// § loopVarParamReadUnbound445
module top;
parameter int item = 2;
int q[$]; int s;
initial s = q.sum() with (item * 2);
endmodule
