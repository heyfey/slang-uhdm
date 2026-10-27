// § foreachLoopVarModParamTs445
module top;
parameter int j = 2;
int m[2][3]; int s;
initial foreach (m[, j]) s = s + j;
endmodule
