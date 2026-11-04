// § loopVarReadBindsModuleDecl439
module top;
int arr[4];
function automatic int f(); int i; int s = 0; foreach (arr[i]) s += arr[i] + i; return s; endfunction
initial $display(f());
endmodule
