// § loopVarParamReadUnbound445
module top;
parameter int i = 2;
logic [3:0] v; int s;
initial foreach (v[i]) s = s + v[i] + i;
endmodule
