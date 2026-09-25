// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
interface ifc; function automatic logic [3:0] g (u_t op); return op.a; endfunction endinterface
function automatic logic [3:0] f (u_t op); return op.a; endfunction
module top(input logic [3:0] i, output logic [3:0] o); ifc u(); assign o = f(i) ^ u.g(i); endmodule
