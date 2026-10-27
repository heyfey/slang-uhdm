// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
initial begin int la[3]; foreach (la[i]) la[i] = i; end
endprogram
