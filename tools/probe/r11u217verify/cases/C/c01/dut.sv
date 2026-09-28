// § caseItemImpWildParamScopeName210 — r11u217 c01: casez / casex items reading wildcard-imported parameters whose value holds x digits, z digits and ? digits, each WITH a concatenation initializer
package tp;
  parameter logic [1:0] OP = 2'b10;
  parameter logic [7:0] I_X = { 3'b01x, 3'b000, {OP} };
  parameter logic [7:0] I_Z = { 3'b01z, 3'b001, {OP} };
  parameter logic [7:0] I_Q = { 3'b011, 3'h?, {OP} };
endpackage
module dut import tp::*; (input logic [7:0] insn, output int o, output int p);
  always_comb begin
    o = 0;
    casez (insn)
      I_Z: o = 1;
      I_Q: o = 2;
      default: o = 0;
    endcase
  end
  always_comb begin
    p = 0;
    casex (insn)
      I_X: p = 3;
      I_Q: p = 4;
      default: p = 0;
    endcase
  end
endmodule
