// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned A; int unsigned B; } cfg_t; localparam cfg_t DEF = '{A: 3, B: 4}; endpackage
module mm #(parameter p::cfg_t C = p::DEF) (output logic [7:0] o); assign o = C.A; endmodule
module top(output logic [7:0] o); mm u(o); endmodule
