// § bitNegTypedOperandSize491
typedef enum logic [7:0] { E0, E4 = 4 } t_t;
module m #(parameter t_t A = E4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o;
m u(o);
endmodule
