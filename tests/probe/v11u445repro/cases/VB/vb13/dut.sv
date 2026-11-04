// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial begin bit signed [5:0] i; foreach (arr[i]) s = s + i; end
endmodule
