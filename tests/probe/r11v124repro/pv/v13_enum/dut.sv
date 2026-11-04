// § paramValueIsDefRhs124
typedef enum logic [1:0] {A, B, C} e_t;
module top(output logic [1:0] o); parameter e_t P = B; assign o = P; endmodule
