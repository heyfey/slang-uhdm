// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s;
wire [3:0] i;
initial foreach (a[i]) foreach (b[i]) s = s + i;
endmodule
