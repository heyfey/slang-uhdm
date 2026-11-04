// § bitNegTypedOperandSize491
module m (output logic [7:0] o);
localparam bit [7:0] A = 4'd4; localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
