// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned A; } in_t; typedef struct { in_t I; int unsigned B; } cfg_t; localparam cfg_t DEF = '{I: '{A: 2}, B: 5}; endpackage
module mm import p::*; #(parameter cfg_t C = DEF) (output logic [7:0] o); assign o = C.B; endmodule
module top(output logic [7:0] o); mm u(o); endmodule
