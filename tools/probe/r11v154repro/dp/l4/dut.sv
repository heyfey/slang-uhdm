// § defPkgStructParamMemberNames154
package p; typedef struct packed { logic [3:0] A; logic [3:0] B; } cfg_t; endpackage
module m #(parameter p::cfg_t C = '{A: 1, B: 2}) (output logic [7:0] o); assign o = C; endmodule
module top(output logic [7:0] o1, o2); m u(o1); m #(.C('{A: 3, B: 4})) v(o2); endmodule
