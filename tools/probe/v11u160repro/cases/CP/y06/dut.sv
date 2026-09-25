// § implNetBareParamElab160
module g(); parameter P = 1'b1; assign #1 o = P; endmodule
module top(); g u(); endmodule
