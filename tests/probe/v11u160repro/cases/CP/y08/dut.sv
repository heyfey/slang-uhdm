// § implNetBareParamElab160
module g(); parameter int P = 3; assign o = P; assign o2 = P + 1; endmodule
module top(); g #(.P(5)) u(); g u2(); endmodule
