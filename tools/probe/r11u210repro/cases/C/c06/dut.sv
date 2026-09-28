// § caseItemImpWildParamScopeName210 — c06: control, the qualified tp::W as a casez item (decode-only: stage 1 on both binaries, golden names the ref tp::W)
package tp;
  parameter logic [1:0] OPX = 2'b01;
  parameter logic [7:0] W = { 4'b0110, 2'b??, {OPX} };
endpackage
module dut (input logic [7:0] insn, output int o);
  always_comb begin
    unique casez (insn)
      tp::W: o = 1;
      default: o = 0;
    endcase
  end
endmodule
