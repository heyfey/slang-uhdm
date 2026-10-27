// § nestedLoopVarSkipsOuter445v
module sub;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endmodule
module top; sub u1(); sub u2(); endmodule
