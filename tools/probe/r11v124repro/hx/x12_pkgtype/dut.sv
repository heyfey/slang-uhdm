// § incDecMemberPathIsLvalue124
package p; typedef struct packed { logic [7:0] cnt; logic v; } s_t; endpackage
module top(input logic clk, output logic [7:0] o); p::s_t s; always_ff @(posedge clk) s.cnt++; assign o = s.cnt; endmodule
