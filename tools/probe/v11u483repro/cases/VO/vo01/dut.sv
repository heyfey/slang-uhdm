// § clsScopedOvRhsRefObj483
class K; typedef enum {RED=3, GRN} c_t; endclass
module m #(parameter int A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(K::RED)) u(o); endmodule
