// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[3];
task automatic t(); endtask
initial foreach (a[i]) begin a[i] = i; t(); end
endprogram
