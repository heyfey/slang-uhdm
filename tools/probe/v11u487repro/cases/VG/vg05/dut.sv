// § caFoldLhsWidthGrow487
typedef logic [7:0] b_t;
module m #(parameter logic [3:0] A = 4) (output b_t o); assign o = A; endmodule
module top; b_t o; m #(.A(5)) u(o); endmodule
