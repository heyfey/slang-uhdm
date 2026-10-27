// § foreachLoopVarModParamTs445
module top;
parameter string i = "x";
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
