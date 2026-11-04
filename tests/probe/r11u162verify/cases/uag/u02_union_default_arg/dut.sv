// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
function automatic logic [3:0] f (u_t op = 4'h3); return op.b; endfunction
module top(output logic [3:0] o); assign o = f(); endmodule
