// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s; int i;
if (1) begin : g initial foreach (a[i]) foreach (b[i]) s = s + i; end
endmodule
