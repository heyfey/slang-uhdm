// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int d[];
initial begin d = new[3]; foreach (d[i]) d[i] = i; end
endprogram
