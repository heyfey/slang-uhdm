// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int arr[4];
task t(); foreach (arr[k]) arr[k] = k; endtask
initial t();
endprogram
