// § nonTrailIdxNamesByChain308
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [3:0] k; t_t [1:0] a; } u_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module l3(input logic [3:0] i, output logic [7:0] r); e_t sa[16]; logic [3:0] m[16]; assign r = sa[m[i] + 1].f; endmodule
module l2(input logic [3:0] i, output logic [7:0] r); l3 u3(.i(i), .r(r)); endmodule
module top(input logic [3:0] i, output logic [7:0] r); l2 u2(.i(i), .r(r)); endmodule
