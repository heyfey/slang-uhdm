// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[4];
initial fork foreach (a[i]) a[i] = i; join
endprogram
