// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
class C; function logic [3:0] m (u_t op); return op.a; endfunction endclass
function automatic logic [3:0] f (u_t op); return op.b; endfunction
module top(input logic [3:0] i, output logic [3:0] o); assign o = f(i); endmodule
