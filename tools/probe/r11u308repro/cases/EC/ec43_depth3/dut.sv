// § elabClsNonTrailIdxUnstored308
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module leaf(input logic [3:0] i, output logic [7:0] r); e_t sa [16]; assign r = sa[i+1].f; endmodule
module mid(input logic [3:0] i, output logic [7:0] r); leaf l(.i(i), .r(r)); endmodule
module top(input logic [3:0] i, output logic [7:0] r); mid u(.i(i), .r(r)); endmodule
