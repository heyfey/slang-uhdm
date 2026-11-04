// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned Z; } l2_t; typedef struct { l2_t L2; } l1_t; typedef struct { l1_t L1; } cfg_t; localparam cfg_t DEF = '{L1: '{L2: '{Z: 6}}}; endpackage
interface tif #(parameter p::cfg_t C = p::DEF); logic [C.L1.L2.Z-1:0] s; endinterface
module top(output logic [5:0] o); tif t(); assign o = t.s; endmodule
