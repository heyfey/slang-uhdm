// § foreachLoopVarModParamTs445
module top;
int arr[4];
genvar i;
initial foreach (arr[i]) arr[i] = i;
endmodule
