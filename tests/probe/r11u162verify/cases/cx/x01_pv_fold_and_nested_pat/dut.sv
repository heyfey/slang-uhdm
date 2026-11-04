// § ifacePortViewFoldAtLeftOperand155 § portViewNestedPatTsNamed154
package tpkg; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } cfg_t; endpackage
interface tif #(parameter tpkg::cfg_t CFG = '{BUS: '{DAT: 32}}, parameter int DAT = 32);
  localparam int unsigned BYT = DAT/8;
  logic [CFG.BUS.DAT-1:0] req;
  logic [BYT-1:0] ben;
  modport sub(input req, input ben);
endinterface
module mc(tif.sub s, output logic [31:0] o, output logic [3:0] b);
  assign o = s.req;
  for (genvar i = 0; i < s.BYT; i++) begin : g
    assign b[i] = s.ben[i];
  end
endmodule
module top(output logic [31:0] o, output logic [3:0] b); tif s(); mc u(.s(s.sub), .o(o), .b(b)); endmodule
