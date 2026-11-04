// § ifacePortViewFoldAtLeftOperand155 § portViewNestedPatTsNamed154
package tpkg; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } cfg_t; endpackage
interface tif #(parameter tpkg::cfg_t CFG = '{BUS: '{DAT: 16}});
  localparam int unsigned BYT = CFG.BUS.DAT/8;
  logic [BYT-1:0] ben;
  modport sub(input ben);
endinterface
module mc(tif s, output logic [1:0] b);
  for (genvar i = 0; i < s.BYT; i++) begin : g
    assign b[i] = s.ben[i];
  end
endmodule
module top(output logic [1:0] b); tif s(); mc u(.s(s), .b(b)); endmodule
