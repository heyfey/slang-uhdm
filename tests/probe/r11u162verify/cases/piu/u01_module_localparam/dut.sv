// § paramInitUnpackedMemberPath154
package p; typedef struct { int unsigned DAT; } bus_t; typedef struct { bus_t BUS; } cfg_t; localparam cfg_t CFG_DEF = '{BUS: '{DAT: 64}}; endpackage
module mm #(parameter p::cfg_t CFG = p::CFG_DEF) (output logic [7:0] o);
  localparam int unsigned BYT = CFG.BUS.DAT/8;
  assign o = BYT;
endmodule
module top(output logic [7:0] o); mm u(o); endmodule
