// § foreachLoopVarModParamTs445
module top;
int arr[4];
parameter type i = int;
int s;
initial foreach (arr[k]) s = s + k;
initial foreach (arr[i]) s = s + 1;
endmodule
