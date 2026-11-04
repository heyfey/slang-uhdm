// § caFoldLhsWidthGrow487
module m #(parameter logic [3:0] A = 4) (output logic [7:0] o); logic [7:0] q; assign q = A; assign o = q; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); endmodule
