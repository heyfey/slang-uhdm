// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
initial fork : nf int i; foreach (arr[i]) arr[i] = i; join
endmodule
