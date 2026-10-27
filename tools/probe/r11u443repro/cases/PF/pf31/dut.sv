// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
initial begin foreach (arr[i]) arr[i] = i; end
endprogram
