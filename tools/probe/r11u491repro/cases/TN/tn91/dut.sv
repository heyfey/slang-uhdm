// § bitNegTypedOperandSize491
typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
module m #(parameter t_t A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
