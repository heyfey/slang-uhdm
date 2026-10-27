// § loopVarReadBindsModuleDecl439
module top;
function automatic int i(); return 1; endfunction
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endmodule
