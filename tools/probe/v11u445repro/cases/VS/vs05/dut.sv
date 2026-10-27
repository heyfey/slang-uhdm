// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s;
initial foreach (a[i]) begin int i; foreach (b[i]) s = s + i; end
endmodule
