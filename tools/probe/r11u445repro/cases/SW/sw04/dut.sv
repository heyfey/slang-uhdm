// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int q[$]; int s;
initial begin int i; foreach (arr[i]) s = s + q.sum() with (item + i); end
endmodule
