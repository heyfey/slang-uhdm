// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
int s;
always_comb begin int i; s = 0; foreach (arr[i]) s = s + i; end
endmodule
