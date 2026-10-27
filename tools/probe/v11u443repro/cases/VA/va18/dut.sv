// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int aa[int]; int s;
initial begin aa[3] = 1; foreach (aa[k]) s = s + k; end
endprogram
