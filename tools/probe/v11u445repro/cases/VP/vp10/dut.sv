// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int m[2][3]; int s;
parameter int j = 1;
initial foreach (m[i, j]) s = s + i + j;
endprogram
