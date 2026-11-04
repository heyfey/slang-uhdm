// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
parameter int i = 2;
initial begin logic [2:0] i; foreach (arr[i]) arr[i] = i; end
endmodule
