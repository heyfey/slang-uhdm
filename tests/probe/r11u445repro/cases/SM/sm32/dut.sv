// § foreachLoopVarModParamTs445
module top;
int arr[4];
parameter int i = 2;
int s;
initial foreach (arr[i]) s = s + arr[i];
endmodule
