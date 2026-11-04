// § dpDepBitNegUint489
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module mid(output logic [7:0] o); m #(.A(3)) u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
