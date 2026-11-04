// § unitAggTfArgLastWriter155
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
module top(input logic [3:0] i, output logic [3:0] o);
function automatic logic [3:0] g (u_t op); return op.a; endfunction
assign o = g(i); endmodule
module other; function automatic logic [3:0] h (u_t op); return op.a; endfunction endmodule
