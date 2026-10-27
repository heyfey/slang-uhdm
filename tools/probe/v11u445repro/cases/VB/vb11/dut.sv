// § foreachLoopVarShadowDeclTs445
module top;
int aa[string]; int s;
initial begin string i; foreach (aa[i]) s = s + aa[i]; end
endmodule
