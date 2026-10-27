// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s; int i;
task automatic t; foreach (a[i]) foreach (b[i]) s = s + i; endtask
endmodule
