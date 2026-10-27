// § nestedLoopVarSkipsOuter445v
interface ifc;
int a[4]; int b[2]; int s;
initial foreach (a[i]) foreach (b[i]) s = s + i;
endinterface
module top; ifc u(); endmodule
