// § foreachPackedRefDeclTs443
module top;
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
s_t sv; int s;
initial foreach (sv[i]) s = s + sv[i];
endmodule
