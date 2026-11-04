// § foreachLoopVarModParamTs445
module top;
parameter i = 4'b0011;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
