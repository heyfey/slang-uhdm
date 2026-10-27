// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
function automatic int f(int x);
  int s;
  foreach (arr[i]) s += arr[i] * i;
  return s + x;
endfunction
initial i = f(1);
endmodule
