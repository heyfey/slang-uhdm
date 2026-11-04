// § bitNegTypedOperandSize491
module m #(parameter type T = logic [7:0], parameter T A = 4'd4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
