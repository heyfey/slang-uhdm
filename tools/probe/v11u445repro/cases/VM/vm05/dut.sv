// § foreachLoopVarModParamTs445
module top;
parameter type i = int;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
