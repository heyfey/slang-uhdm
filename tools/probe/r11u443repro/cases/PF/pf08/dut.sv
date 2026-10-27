// § elabProgMemberArrLoopVar443
module top; prg p1(); prg p2(); endmodule
program prg;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endprogram
