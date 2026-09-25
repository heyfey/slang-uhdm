// § defPkgStructParamMemberNames154
package p; typedef struct packed { logic [3:0] A; logic [3:0] B; } cfg_t; endpackage
module m import p::*; #(parameter cfg_t C = '{A: 1, B: 2}) (output logic [7:0] o); assign o = C; endmodule
module top(output logic [7:0] o); m u(o); endmodule
