// § elabProgMemberArrLoopVar443
class C; int x; endclass
module top; prg p(); endmodule
program prg;
C ca[2];
initial foreach (ca[i]) ca[i] = new;
endprogram
