// § castTsFile124
module top #(parameter W = 5) (output logic [W-1:0] o); logic [15:0] a = 16'hAB; assign o = W'(a); endmodule
