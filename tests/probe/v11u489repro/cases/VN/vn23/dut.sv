// § dpDepBitNegUint489
module top(output logic [7:0] o); localparam A = 4; localparam B = ~A; assign o = B; endmodule
