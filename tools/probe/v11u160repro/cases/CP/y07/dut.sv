// § implNetBareParamElab160
module g(); parameter string S = "ab"; parameter int P = 4; assign o = P; endmodule
module top(); g #(.S("cd")) u(); endmodule
