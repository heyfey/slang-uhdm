// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
class C; endclass
initial begin C i; foreach (arr[i]) s = s + i; end
endmodule
