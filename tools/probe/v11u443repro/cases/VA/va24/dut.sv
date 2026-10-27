// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
string a[3]; string s;
initial foreach (a[i]) s = a[i];
endprogram
