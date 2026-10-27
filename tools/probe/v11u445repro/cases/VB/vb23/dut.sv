// § foreachLoopVarShadowDeclTs445
module top;
logic [3:0] v; int s;
initial begin int i; foreach (v[i]) s = s + i; end
endmodule
