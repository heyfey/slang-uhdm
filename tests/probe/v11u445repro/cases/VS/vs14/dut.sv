// § nestedLoopVarSkipsOuter445v
module top;
parameter int i = 2;
int a[4]; int b[2]; int s;
initial foreach (a[i]) begin s = s + i; foreach (b[i]) s = s + i; end
endmodule
