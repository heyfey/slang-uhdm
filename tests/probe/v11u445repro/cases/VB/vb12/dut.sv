// § foreachLoopVarShadowDeclTs445
module top;
int dq[$]; int da[]; int s;
initial begin int i; foreach (dq[i]) s = s + i; foreach (da[i]) s = s + i; end
endmodule
