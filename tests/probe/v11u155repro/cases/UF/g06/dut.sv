// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
function automatic logic [3:0] f (input u_t op, input u_t op2); return op.a ^ op2.b; endfunction
module top(input logic [3:0] i, output logic [3:0] o); assign o = f(i, i); endmodule
