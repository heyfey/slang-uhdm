// § defPkgStructParamMemberNames154
package p; typedef union packed { logic [7:0] A; logic [7:0] B; } cfg_t; endpackage
module m #(parameter p::cfg_t C = 8'h5) (output logic [7:0] o); assign o = C.A; endmodule
module top(output logic [7:0] o); m u(o); endmodule
