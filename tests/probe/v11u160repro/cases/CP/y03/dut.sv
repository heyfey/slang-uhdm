// § implNetBareParamElab160
module g(); parameter logic [3:0] P = 4'h3; assign o = P; endmodule
module top(); g u1(); g #(.P(4'h9)) u2(); endmodule
