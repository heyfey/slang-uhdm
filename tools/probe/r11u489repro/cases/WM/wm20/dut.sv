// § untypedDepUnboundedValue489
module m #(parameter A = 2'd3, parameter B = A + 2'd3) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
