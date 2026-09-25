// § defPkgStructParamMemberNames154
package p; typedef struct packed { logic [3:0] A; logic [3:0] B; } cfg_t; endpackage
module mm #(parameter p::cfg_t C = '{A: 1, B: 2}) (output logic [7:0] o); assign o = C.A + C.B; endmodule
module top(output logic [7:0] o1, o2); mm u1(o1); mm #(.C('{A: 3, B: 4})) u2(o2); endmodule
