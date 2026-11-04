// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
int x;
initial foreach (arr[i]) begin x = i; if (i > 1) x = arr[i]; end
endprogram
