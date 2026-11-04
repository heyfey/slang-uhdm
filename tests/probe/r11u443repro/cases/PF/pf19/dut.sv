// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
initial foreach (arr[i]) s += arr[i] + i;
endprogram
