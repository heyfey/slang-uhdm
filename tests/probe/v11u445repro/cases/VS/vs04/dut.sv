// § nestedLoopVarSkipsOuter445v
module top;
int m[2][3]; int b[2]; int s;
initial begin int i; foreach (m[i, j]) foreach (b[i]) s = s + i + j; end
endmodule
