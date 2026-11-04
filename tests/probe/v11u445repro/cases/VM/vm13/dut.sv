// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int m[2][3]; int s;
initial foreach (m[i, j]) s = s + i + j;
endmodule
