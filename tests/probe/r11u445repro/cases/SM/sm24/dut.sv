// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
initial begin : outer int i; begin : inner foreach (arr[i]) arr[i] = i; end end
endmodule
