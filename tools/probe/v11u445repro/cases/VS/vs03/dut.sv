// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int c[3]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) foreach (c[i]) s = s + i; end
endmodule
