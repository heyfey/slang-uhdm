// § foreachLoopVarModParamTs445
module top;
int arr[4];
initial begin localparam int i = 1; foreach (arr[i]) arr[i] = i; end
endmodule
