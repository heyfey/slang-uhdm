// § regTdArrElabIsNet251
typedef struct packed { reg [1:0] a; } s_t;
typedef s_t a_t[4];
module top; logic a; a_t x; logic b; endmodule
