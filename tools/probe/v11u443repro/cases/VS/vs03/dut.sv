// § elabProgMemberArrLoopVar443
typedef logic [3:0] v_t;
module top; prg p(); endmodule
program prg;
v_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
