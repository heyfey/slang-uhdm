// § unitAggTfArgLastWriter155
typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
task automatic t (input s_t op, output logic [1:0] r); r = op.b; endtask
function automatic logic [1:0] f (s_t op); return op.a; endfunction
module top(input logic [3:0] i, output logic [3:0] o); assign o = {2'b0, f(i)}; endmodule
