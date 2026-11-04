// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
function automatic void f(int i); foreach (arr[i]) arr[i] = i; endfunction
endmodule
