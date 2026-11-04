// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
int s;
always @* begin int i; foreach (arr[i]) s = s + i; end
endmodule
