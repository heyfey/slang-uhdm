// § foreachLoopVarShadowDeclTs445
module sub;
int arr[4];
initial begin int i; foreach (arr[i]) arr[i] = i; end
endmodule
module top; sub u1(); sub u2(); endmodule
