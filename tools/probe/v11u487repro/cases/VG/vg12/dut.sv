// § caFoldLhsWidthGrow487
module m #(parameter logic [3:0] A = 4) (output o); assign o = A; endmodule
module top; logic o; m #(.A(5)) u(o); endmodule
