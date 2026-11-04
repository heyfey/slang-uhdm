// § foreachLoopVarModParamTs445
module top;
int arr[4];
localparam int K = 3;
initial foreach (arr[K]) arr[K] = K;
endmodule
