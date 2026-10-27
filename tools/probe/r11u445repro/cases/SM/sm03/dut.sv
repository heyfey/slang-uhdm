// § foreachLoopVarModParamTs445
module top;
int arr[4];
parameter int i = 2;
initial foreach (arr[i]) arr[i] = i;
endmodule
