// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) s += i; end
endmodule
