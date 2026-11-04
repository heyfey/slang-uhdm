// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o); localparam [7:0] B = A + 4'd1; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
