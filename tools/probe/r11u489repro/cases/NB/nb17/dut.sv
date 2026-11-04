// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o); parameter B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
