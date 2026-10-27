// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial begin int i; fork foreach (arr[i]) s = s + i; join end
endmodule
