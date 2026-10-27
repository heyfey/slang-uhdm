// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial begin real i; foreach (arr[i]) s = s + i; end
endmodule
