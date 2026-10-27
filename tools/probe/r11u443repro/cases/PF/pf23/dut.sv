// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
typedef struct { int a; } st_t;
st_t sa[3];
initial foreach (sa[k]) sa[k].a = k;
endprogram
