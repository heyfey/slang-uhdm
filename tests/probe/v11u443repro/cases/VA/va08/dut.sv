// § elabProgMemberArrLoopVar443
module top; for (genvar g = 0; g < 2; g++) begin : gb prg p(); end endmodule
program prg;
int a[3];
initial foreach (a[i]) a[i] = i;
endprogram
