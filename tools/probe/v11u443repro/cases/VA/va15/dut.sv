// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[3]; int b[3];
initial foreach (a[i]) begin b[i] = a[i]; $display("%0d", i); end
endprogram
