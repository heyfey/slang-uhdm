// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned A; int unsigned B; } cfg_t; localparam cfg_t D = '{A: 1, B: 2}; endpackage
module m #(parameter p::cfg_t C = p::D) (output logic [7:0] o); localparam p::cfg_t E = C; assign o = E.B; endmodule
module top(output logic [7:0] o); m u(o); endmodule
