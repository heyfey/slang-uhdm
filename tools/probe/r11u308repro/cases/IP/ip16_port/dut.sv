// § nonTrailIdxIpsLeaf308
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [3:0] k; t_t [1:0] a; } u_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module sub(input logic [7:0] a); endmodule
module top(input logic [3:0] i); e_t sa [16]; t_t t; sub u1(.a(sa[t.idx[i +: 1]].f)); endmodule
