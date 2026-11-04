// § elabProgMemberArrLoopVar443
module top; prg #(3) p(); endmodule
program prg #(parameter N = 2);
int arr[N];
initial foreach (arr[i]) arr[i] = i;
endprogram
