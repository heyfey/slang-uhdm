// § foreachLoopVarModParamTs445
module top;
int arr[4];
parameter int i = 2;
function automatic void f(); foreach (arr[i]) arr[i] = i; endfunction
endmodule
