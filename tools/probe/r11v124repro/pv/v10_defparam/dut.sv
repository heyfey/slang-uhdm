// § paramValueIsDefRhs124
module m(output logic [7:0] o); parameter W = 4; assign o = W; endmodule
module top(output logic [7:0] o); m u(.o(o)); defparam u.W = 8; endmodule
