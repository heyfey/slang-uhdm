// § foreachLoopVarModParamTs445
parameter int i = 7;
module top;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
