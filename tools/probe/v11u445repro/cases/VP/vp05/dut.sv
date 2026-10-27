// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
typedef struct { logic [1:0] f; } st_t;
st_t sa[3]; int s;
parameter int i = 1;
initial foreach (sa[i]) s = s + i;
endprogram
