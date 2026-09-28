// § caseItemImpWildParamScopeName210 — c05: control, a module-local wildcard parameter as a casez item (not imported: the law does not fire)
module dut (input logic [7:0] insn, output int o);
  localparam logic [1:0] OPX = 2'b01;
  localparam logic [7:0] LW = { 4'b1110, 2'b??, {OPX} };
  always_comb begin
    unique casez (insn)
      LW: o = 2;
      default: o = 0;
    endcase
  end
endmodule
