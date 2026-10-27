// § loopVarParamReadUnbound445
module top;
int item;
int q[$]; int s;
initial s = q.sum() with (item * 2);
endmodule
