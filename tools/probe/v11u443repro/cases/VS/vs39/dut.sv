// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
var logic [3:0] a [3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
