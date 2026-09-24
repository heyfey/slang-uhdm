// § realLitValueIsText124
module m #(parameter real R = 1.5) (output real o); real k = R * 0.5; assign o = k; endmodule
module top(output real o); m #(.R(3.0)) u(.o(o)); endmodule
