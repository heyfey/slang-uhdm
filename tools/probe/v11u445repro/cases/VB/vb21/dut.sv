// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) begin int k; k = i; s = s + k; end end
endmodule
