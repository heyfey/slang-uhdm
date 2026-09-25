// § unitAggTfArgLastWriter155
typedef logic [3:0] v_t;
function automatic logic [3:0] f (v_t op); return op; endfunction
module top(input logic [3:0] i, output logic [3:0] o); assign o = f(i); endmodule
