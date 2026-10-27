// § foreachLoopVarModParamTs445
module top;
int arr[4];
localparam logic [3:0] i = 2;
initial foreach (arr[i]) arr[i] = i;
endmodule
