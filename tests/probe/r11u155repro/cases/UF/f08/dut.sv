// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
function automatic u_t f (logic [3:0] op); return op; endfunction
module top(input logic [3:0] i, output logic [3:0] o); assign o = f(i); endmodule
