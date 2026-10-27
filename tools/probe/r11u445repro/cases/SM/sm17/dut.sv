// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
int b[2]; int s;
initial foreach (arr[i]) foreach (b[i]) s = s + i;
endmodule
