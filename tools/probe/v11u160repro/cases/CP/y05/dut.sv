// § implNetBareParamElab160
module g(input logic a); parameter int P = 1; assign o = P; assign o3 = a; endmodule
module top(input logic a); g #(.P(7)) u(a); endmodule
