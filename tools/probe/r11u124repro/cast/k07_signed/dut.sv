// § castTsFile124
module top(output logic signed [7:0] o); logic [7:0] a = 8'hAB; assign o = signed'(a); endmodule
