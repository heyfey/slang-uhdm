// § foreachLoopVarShadowDeclTs445
module top;
int q[$]; int s;
initial begin int i; s = q.sum() with (i * 2); end
endmodule
