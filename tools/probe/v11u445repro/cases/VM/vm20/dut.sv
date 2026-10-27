// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
initial std::randomize(arr) with { foreach (arr[i]) arr[i] < i; };
endmodule
