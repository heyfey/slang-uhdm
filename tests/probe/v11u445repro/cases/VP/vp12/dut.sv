// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int aa[string]; int s;
parameter int i = 1;
initial foreach (aa[i]) s = s + aa[i];
endprogram
