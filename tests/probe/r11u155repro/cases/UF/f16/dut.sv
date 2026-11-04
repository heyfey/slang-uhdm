// § unitAggTfArgLastWriter155
typedef struct packed { logic [3:0] a; } s_t;
module top(input logic [3:0] i, output logic [3:0] o);
function automatic logic [3:0] f (s_t op); return op.a; endfunction
assign o = f(i); endmodule
