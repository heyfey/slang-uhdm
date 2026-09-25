// § unitAggTfArgLastWriter155
typedef enum logic [1:0] {A, B} e_t;
function automatic logic [1:0] f (e_t op); return op; endfunction
module top(input logic [1:0] i, output logic [1:0] o); assign o = f(e_t'(i)); endmodule
