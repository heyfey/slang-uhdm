// § caFoldLhsWidthGrow487
module m #(parameter logic [3:0] A = 4) (output wire [7:0] o); assign o = A; endmodule
module top; wire [7:0] o; m #(.A(5)) u(o); endmodule
