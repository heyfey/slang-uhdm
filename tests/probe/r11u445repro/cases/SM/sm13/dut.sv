// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
initial fork int i; foreach (arr[i]) arr[i] = i; join
endmodule
