// § untypedDepUnboundedValue489
module m #(parameter A = 4'd15) (output logic [7:0] o); localparam B = A + 4'd1; localparam W = B; logic [W-1:0] x; assign x = '1; assign o = W; endmodule
module top; logic [7:0] o; m u(o); endmodule
