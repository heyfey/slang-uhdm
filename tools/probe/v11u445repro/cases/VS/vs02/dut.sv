// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s;
task automatic t(input int i); foreach (a[i]) foreach (b[i]) s = s + i; endtask
endmodule
