// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
byte arr[4];
int s;
initial foreach (arr[i]) s = s + i;
endprogram
