// § bitNegTypedOperandSize491
typedef enum logic [3:0] {E0, E1} e_t;
module m #(parameter e_t A = E1) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
