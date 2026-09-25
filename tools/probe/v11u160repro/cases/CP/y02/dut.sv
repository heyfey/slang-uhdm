// § implNetBareParamElab160
module g(); parameter int P = 3; localparam int L = P * 2; assign o = L; endmodule
module top(); g #(.P(5)) u(); endmodule
