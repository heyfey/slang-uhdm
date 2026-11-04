// § unboundedSubSize64_491
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; assign o = B; endmodule
module top; logic [7:0] o, o2; m u(o); m #(.A(4'd9)) u2(o2); endmodule
