// § foreachPackedRefDeclTs443
module top;
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
s_t ps; int s;
initial foreach (ps[i]) s = s + i;
endmodule
