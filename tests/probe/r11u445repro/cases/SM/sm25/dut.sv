// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
function automatic void f(); begin int i; foreach (arr[i]) arr[i] = i; end endfunction
endmodule
