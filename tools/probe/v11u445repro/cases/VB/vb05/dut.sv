// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial begin int i[2]; foreach (arr[i]) s = s + i; end
endmodule
