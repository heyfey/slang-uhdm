// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
logic [7:0] i;
int s;
initial foreach (arr[i]) s = s + i;
endmodule
