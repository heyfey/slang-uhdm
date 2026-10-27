// § foreachLoopVarModParamTs445
module top(i);
int arr[4];
input [3:0] i;
int s;
initial foreach (arr[i]) s = s + i;
endmodule
