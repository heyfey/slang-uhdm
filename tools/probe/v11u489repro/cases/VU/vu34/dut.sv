// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15, parameter B = A + 4'd1, parameter C = B + 4'd1) (output logic [7:0] o); assign o = C; endmodule
module top; logic [7:0] o; m #(.B(3)) u(o); endmodule
