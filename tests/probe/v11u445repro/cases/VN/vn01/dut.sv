// § foreachLoopVarShadowDeclTs445
module top;
int a[4]; int b[2]; int s; int i;
initial foreach (a[i]) foreach (b[i]) s = s + i;
endmodule
