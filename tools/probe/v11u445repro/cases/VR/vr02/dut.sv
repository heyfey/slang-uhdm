// § loopVarParamReadUnbound445
module top;
parameter int x = 2;
int q[$]; int r[$];
initial r = q.find(x) with (x > 1);
endmodule
