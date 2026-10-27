// § foreachLoopVarModParamTs445
module sub #(parameter int W = 2);
parameter logic [W-1:0] i = 1;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
module top; sub u1(); sub #(.W(4)) u2(); endmodule
