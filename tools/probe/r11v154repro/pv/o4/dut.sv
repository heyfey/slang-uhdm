// § portViewNestedPatTsNamed154
package tpkg; typedef struct packed { int unsigned DAT; int unsigned ADR; } bus_t; typedef struct packed { bus_t BUS; bus_t AUX; } cfg_t; endpackage
interface tif #(parameter tpkg::cfg_t CFG = '{BUS: '{DAT: 32, ADR: 4}, AUX: '{DAT: 8, ADR: 2}}); logic [CFG.BUS.DAT-1:0] req; modport sub(input req); endinterface
module mc(tif.sub s, output logic [31:0] o); assign o = s.req; endmodule
module top(output logic [31:0] o); tif s(); mc u(.s(s.sub), .o(o)); endmodule
