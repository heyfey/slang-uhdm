// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned A; int unsigned B; } cfg_t; localparam cfg_t D = '{A: 1, B: 2}; endpackage
module m #(parameter p::cfg_t C = p::D) (output logic [7:0] o); assign o = C.A; endmodule
module top(output logic [7:0] o1, o2); m u(o1); m #(.C('{A: 3, B: 4})) v(o2); endmodule
