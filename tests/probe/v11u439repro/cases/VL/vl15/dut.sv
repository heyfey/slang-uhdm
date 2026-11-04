// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
class C;
  int a[2];
  function void f(); foreach (a[i]) a[i] = i; endfunction
endclass
initial foreach (arr[i]) arr[i] = i;
endmodule
