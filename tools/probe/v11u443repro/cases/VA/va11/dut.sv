// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[4];
initial begin : nb foreach (a[i]) a[i] = i; end
endprogram
