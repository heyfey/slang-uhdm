// § pkgSubLoopVarReadBindsDecl445
package pk;
class C; int arr[4]; int s;
function void f(); int i; foreach (arr[i]) s = s + i; endfunction
endclass
endpackage
module top; pk::C c = new; endmodule
