// § implNetBareParamElab160
module g(); parameter int P = 0; assign o = P; endmodule
module s(); parameter int Q = 0; g #(.P(Q)) u(); endmodule
module top(); s #(.Q(20)) u(); endmodule
