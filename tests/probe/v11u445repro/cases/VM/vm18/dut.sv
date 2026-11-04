// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
function automatic int f(); int r; foreach (arr[i]) r = r + i; return r; endfunction
assign s = f();
endmodule
