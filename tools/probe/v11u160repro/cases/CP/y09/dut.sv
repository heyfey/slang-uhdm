// § implNetBareParamElab160
module g(output logic q); parameter int P = 3; assign o = P; assign q = o; endmodule
module top(output logic q); g #(.P(1)) u(q); endmodule
