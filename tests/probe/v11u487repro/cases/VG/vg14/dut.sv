// § caFoldLhsWidthGrow487
module m #(parameter bit [3:0] A = 4) (output bit [7:0] o); assign o = A; endmodule
module top; bit [7:0] o; m #(.A(5)) u(o); endmodule
