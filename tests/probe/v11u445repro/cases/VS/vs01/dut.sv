// § nestedLoopVarSkipsOuter445v
interface ifc;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule
