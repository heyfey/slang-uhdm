// § nestedLoopVarSkipsOuter445v
module top; prg p(); endmodule
program prg;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endprogram
