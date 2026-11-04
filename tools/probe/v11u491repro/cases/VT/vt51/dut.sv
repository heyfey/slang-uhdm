// § bitNegTypedOperandSize491
typedef logic signed [7:0] s8_t;
module m #(parameter s8_t A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
