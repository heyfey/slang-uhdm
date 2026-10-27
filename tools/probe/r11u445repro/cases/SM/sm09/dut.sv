// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
int i;
initial foreach (arr[i]) arr[i] = i;
endmodule
