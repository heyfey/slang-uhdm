// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
always_comb begin s = 0; foreach (arr[i]) s = s + i; end
endmodule
