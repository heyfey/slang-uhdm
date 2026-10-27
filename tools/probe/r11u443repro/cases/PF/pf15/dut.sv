// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
initial begin : nb fork foreach (arr[i]) arr[i] = i; join end
endprogram
