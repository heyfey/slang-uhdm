// § foreachLoopVarShadowDeclTs445
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
function automatic void f(int i); foreach (arr[i]) s = s + i; endfunction
endprogram
