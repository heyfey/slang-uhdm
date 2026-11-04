// § caFoldLhsWidthGrow487
module m #(parameter logic [3:0] A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o1, o2; m #(.A(5)) u1(o1); m #(.A(6)) u2(o2); endmodule
