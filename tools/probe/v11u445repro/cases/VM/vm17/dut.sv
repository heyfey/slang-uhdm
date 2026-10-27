// § foreachLoopVarModParamTs445
module sub;
parameter int i = 2;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
module top; defparam u.i = 5; sub u(); endmodule
