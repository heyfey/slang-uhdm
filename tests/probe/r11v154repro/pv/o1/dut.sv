// § portViewNestedPatTsNamed154
package tpkg; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } mid_t; typedef struct packed { mid_t MID; } cfg_t; endpackage
interface tif #(parameter tpkg::cfg_t CFG = '{MID: '{BUS: '{DAT: 32}}}); logic [CFG.MID.BUS.DAT-1:0] req; modport sub(input req); endinterface
module mc(tif.sub s, output logic [31:0] o); assign o = s.req; endmodule
module top(output logic [31:0] o); tif s(); mc u(.s(s.sub), .o(o)); endmodule
