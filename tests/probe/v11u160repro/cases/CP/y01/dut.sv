// § implNetBareParamElab160
module g(); parameter int P = 0; assign o1 = P; assign o2 = P; endmodule
module top(); g #(.P(5)) u(); endmodule
