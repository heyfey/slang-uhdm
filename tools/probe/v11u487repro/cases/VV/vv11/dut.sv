// § caFoldValueFollowsPa487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A ? 8'hF0 : 8'h0F; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
