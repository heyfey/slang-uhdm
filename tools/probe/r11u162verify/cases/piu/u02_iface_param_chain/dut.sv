// § paramInitUnpackedMemberPath154
package p; typedef struct { int unsigned DAT; int unsigned ADR; } bus_t; typedef struct { bus_t BUS; } cfg_t; localparam cfg_t CFG_DEF = '{BUS: '{DAT: 32, ADR: 16}}; endpackage
interface tif #(parameter p::cfg_t CFG = p::CFG_DEF);
  localparam int unsigned AW = CFG.BUS.ADR;
  localparam int unsigned DW = CFG.BUS.DAT - AW;
  logic [DW-1:0] w;
endinterface
module top(output logic [15:0] o); tif t(); assign o = t.w; endmodule
