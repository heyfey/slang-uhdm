// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
class C; int a[4]; int s; function void f(); begin int i; foreach (a[i]) s = s + i; end endfunction endclass
C c = new;
endmodule
