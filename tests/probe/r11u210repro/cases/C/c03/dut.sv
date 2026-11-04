// § caseItemImpWildParamScopeName210 — c03: a case item inside a generate block's always_comb, and a control if condition reading the same imported parameter
package tp;
  parameter logic [1:0] OPX = 2'b01;
  parameter logic [7:0] W = { 4'b0110, 2'b??, {OPX} };
endpackage
module dut import tp::*; (input logic [7:0] insn, output int p, output int q);
  always_comb begin
    if (insn ==? W) p = 1;
    else p = 0;
  end
  if (1) begin : g
    always_comb begin
      casez (insn)
        W: q = 7;
        default: q = 0;
      endcase
    end
  end
endmodule
