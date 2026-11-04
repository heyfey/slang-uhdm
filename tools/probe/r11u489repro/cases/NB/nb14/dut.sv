// § dpDepBitNegUint489
module m #(parameter A = 0) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
