// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
task automatic t; foreach (arr[i]) s = s + i; endtask
endmodule
