// § foreachLoopVarShadowDeclTs445
module top;
int m[2][3]; int s;
initial begin int j; foreach (m[i, j]) s = s + i + j; end
endmodule
