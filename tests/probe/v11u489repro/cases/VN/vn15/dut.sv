// § dpDepBitNegUint489
module top(output logic [7:0] o); parameter A = 4; localparam B = ~A; assign o = B; endmodule
