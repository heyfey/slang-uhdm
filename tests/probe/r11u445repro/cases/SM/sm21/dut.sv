// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
int m[2][3]; int s;
initial begin int i; foreach (m[j, i]) s = s + i + j; end
endmodule
