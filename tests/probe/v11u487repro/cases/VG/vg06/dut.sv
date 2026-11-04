// § caFoldLhsWidthGrow487
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter logic [3:0] A = 4) (output s_t o); assign o = A; endmodule
module top; s_t o; m #(.A(5)) u(o); endmodule
