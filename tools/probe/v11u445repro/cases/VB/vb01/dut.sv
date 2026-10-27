// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
initial for (int i = 0; i < 1; i++) foreach (arr[i]) s = s + i;
endmodule
