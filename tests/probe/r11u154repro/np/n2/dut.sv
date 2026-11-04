// § defPkgStructParamMemberNames154
package tpkg; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } cfg_t; endpackage
interface tif #(parameter tpkg::cfg_t CFG = '{BUS: '{DAT: 32}}); logic [CFG.BUS.DAT-1:0] req; endinterface
module top(output logic [31:0] o); tif s(); assign o = s.req; endmodule
