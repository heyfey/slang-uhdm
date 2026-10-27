// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
logic a [3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
