// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
function automatic int i(); foreach (arr[i]) arr[i] = 1; return 0; endfunction
endmodule
