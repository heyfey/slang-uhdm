// § dynArrNewElemLvalueBase437
module top;
typedef struct { int d[]; } s_t;
s_t s[2];
initial s[0].d = new[3];
endmodule
