// § foreachLoopVarShadowDeclTs445
module top;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endmodule
