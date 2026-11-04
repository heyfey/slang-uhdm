// § caFoldLhsWidthGrow487
module m #(parameter logic [3:0] A = 4); int o; assign o = A; endmodule
module top; m #(.A(5)) u(); endmodule
