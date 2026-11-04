// § incDecMemberPathIsLvalue124
typedef union packed { logic [7:0] x; logic [7:0] y; } u_t;
module top(input logic clk, output logic [7:0] o); u_t u; always @(posedge clk) u.x++; assign o = u.y; endmodule
