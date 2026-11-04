// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
int m[2][3]; int s;
initial begin int i; int j; foreach (m[i, j]) s = s + i + j; end
endmodule
