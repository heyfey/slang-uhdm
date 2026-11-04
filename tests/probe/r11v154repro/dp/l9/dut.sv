// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned A; } in_t; typedef struct { in_t I; int unsigned B; } cfg_t; localparam cfg_t D = '{I: '{A: 1}, B: 2}; endpackage
interface tif #(parameter p::cfg_t C = p::D); logic [C.I.A:0] s; endinterface
module mm #(parameter p::cfg_t K = p::D) (tif t, output logic [7:0] o); assign o = t.s + K.B; endmodule
module top(output logic [7:0] o); tif t(); mm u(t, o); endmodule
