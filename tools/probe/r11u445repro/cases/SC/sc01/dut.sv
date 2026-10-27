// § foreachLoopVarShadowDeclTs445
class C;
int arr[4]; int s;
function void f(); begin int i; foreach (arr[i]) s = s + i; end endfunction
endclass
module top; C c = new; endmodule
