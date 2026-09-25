// § defPkgStructParamMemberNames154
package p; typedef struct packed { logic [3:0] A; logic [3:0] B; } cfg_t; endpackage
module mm import p::*; #(parameter cfg_t C = '{A: 5, B: 6}) (output logic [7:0] o); assign o = C.B; endmodule
module top(output logic [7:0] o); mm u(o); endmodule
