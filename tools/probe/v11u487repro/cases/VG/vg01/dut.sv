// § caFoldLhsWidthGrow487
module m #(parameter logic [3:0] A = 4) (output int o); assign o = A; endmodule
module top; int o; m #(.A(5)) u(o); endmodule
