// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
wire [3:0] i;
int s;
initial foreach (arr[i]) s = s + i;
endmodule
