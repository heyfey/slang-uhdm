// § elabProgMemberArrLoopVar443
module top; prg #(4) p(); endmodule
program prg #(parameter N = 2);
int a[N];
initial foreach (a[i]) a[i] = i;
endprogram
