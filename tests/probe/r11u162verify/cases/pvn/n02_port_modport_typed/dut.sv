// § portViewNestedPatTsNamed154
package tpkg; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } cfg_t; endpackage
interface tif #(parameter tpkg::cfg_t CFG = '{BUS: '{DAT: 8}}); logic [CFG.BUS.DAT-1:0] req; modport sub(input req); endinterface
module mc(tif.sub s, output logic [7:0] o); assign o = s.req; endmodule
module top(output logic [7:0] o); tif s(); mc u(.s(s), .o(o)); endmodule
