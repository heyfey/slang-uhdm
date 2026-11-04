// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) begin s = s + i; foreach (b[i]) s = s + i; s = s + i; end end
endmodule
