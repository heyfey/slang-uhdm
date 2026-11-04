// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
initial begin : nb foreach (arr[i]) begin : inner arr[i] = i; end end
endprogram
