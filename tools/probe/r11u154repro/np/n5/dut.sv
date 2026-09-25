// § defPkgStructParamMemberNames154
package tpkg; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } cfg_t; endpackage
module top(output logic [31:0] o); localparam tpkg::cfg_t C = '{BUS: '{DAT: 32}}; assign o = C.BUS.DAT; endmodule
