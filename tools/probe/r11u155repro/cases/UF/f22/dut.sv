// § unitAggTfArgLastWriter155
typedef struct packed { logic [3:0] a; } s_t;
function automatic logic [3:0] f (s_t op); return op.a; endfunction
module top(input logic [3:0] i, output logic [3:0] o); s_t x [2]; assign x[0] = i; assign o = f(x[0]); endmodule
