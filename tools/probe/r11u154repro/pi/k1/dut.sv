// § defPkgStructParamMemberNames154
package p; typedef struct { int unsigned DAT; } bus_t; typedef struct { bus_t BUS; } cfg_t; localparam cfg_t CFG_DEF = '{BUS: '{DAT: 32}}; endpackage
module m #(parameter p::cfg_t C = p::CFG_DEF) (output logic [7:0] o); localparam int unsigned X = C.BUS.DAT/8; assign o = X; endmodule
module top(output logic [7:0] o); m u(o); endmodule
