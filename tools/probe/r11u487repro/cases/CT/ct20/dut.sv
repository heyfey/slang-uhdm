// § caFoldTsFollowsPa487
module top #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
