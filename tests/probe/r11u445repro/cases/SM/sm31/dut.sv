// § foreachLoopVarModParamTs445
module sub;
parameter logic [3:0] i = 2;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endmodule
module top; sub u1(); sub #(.i(3)) u2(); endmodule
