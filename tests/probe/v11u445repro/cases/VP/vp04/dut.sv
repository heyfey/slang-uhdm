// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int da[]; int s;
parameter int i = 1;
initial foreach (da[i]) s = s + i;
endprogram
