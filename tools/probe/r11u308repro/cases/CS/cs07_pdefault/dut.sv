// § nonTrailIdxNamesByChain308
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module sub #(parameter e_t P [2] = '{default:0}) (input logic [3:0] i, output logic [7:0] r); assign r = P[i+1].f; endmodule
module top(input logic [3:0] i, output logic [7:0] r); sub u(.i(i), .r(r)); endmodule
