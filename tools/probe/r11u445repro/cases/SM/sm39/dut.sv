// § foreachLoopVarModParamTs445
module top;
int arr[4];
parameter int i = 2;
int b[3]; int s;
initial foreach (arr[i]) foreach (b[j]) s = s + i + j;
endmodule
