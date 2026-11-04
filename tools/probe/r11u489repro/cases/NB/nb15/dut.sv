// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [31:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [31:0] o; m u(o); endmodule
