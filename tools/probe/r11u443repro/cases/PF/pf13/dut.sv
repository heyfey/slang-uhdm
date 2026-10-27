// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
final foreach (arr[i]) arr[i] = i;
endprogram
