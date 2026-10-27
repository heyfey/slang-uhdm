// § foreachLoopVarShadowDeclTs445
module top;
int m[2][3]; int s;
initial begin int j; foreach (m[, j]) s = s + j; end
endmodule
