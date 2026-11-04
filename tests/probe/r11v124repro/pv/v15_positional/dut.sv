// § paramValueIsDefRhs124
module m (output logic [3:0] o); parameter A = 1; parameter B = 2; assign o = A + B; endmodule
module top(output logic [3:0] o); m #(5, 6) u(.o(o)); endmodule
