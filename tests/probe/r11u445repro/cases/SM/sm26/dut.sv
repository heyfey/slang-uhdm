// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
initial begin int i; int j; foreach (arr[j]) arr[j] = j; end
endmodule
