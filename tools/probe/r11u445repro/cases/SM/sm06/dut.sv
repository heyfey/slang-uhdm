// § foreachLoopVarModParamTs445
module top(input logic [3:0] i);
int arr[4];
int s;
initial foreach (arr[i]) s = s + i;
endmodule
