// § implNetBareParamElab160
module g(); parameter P = 3; assign o = P; endmodule
module top(); g #(.P(9)) u(); endmodule
