// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int q[$]; int s;
initial foreach (a[i]) s = s + q.sum(i) with (i * 2);
endmodule
