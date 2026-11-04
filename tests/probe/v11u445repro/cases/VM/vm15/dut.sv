// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
initial foreach (arr[i]) foreach (arr[i]) s = s + i;
endmodule
