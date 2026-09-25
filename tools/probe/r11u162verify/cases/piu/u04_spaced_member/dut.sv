// § paramInitUnpackedMemberPath154
package p; typedef struct { int unsigned DAT; } bus_t; typedef struct { bus_t BUS; } cfg_t; localparam cfg_t CFG_DEF = '{BUS: '{DAT: 32}}; endpackage
interface tif #(parameter p::cfg_t CFG = p::CFG_DEF); localparam int unsigned BYT = CFG . BUS . DAT / 8; logic [BYT-1:0] w; endinterface
module top(output logic [3:0] o); tif t(); assign o = t.w; endmodule
