// § caseItemImpWildParamScopeName210 — c02: an explicit import (import tp::W_A), a case (not casez), and a task body
package tp;
  parameter logic [1:0] OPX = 2'b01;
  parameter logic [7:0] W_A = { 2'b10, 4'h?, {OPX} };
  parameter logic [7:0] W_B = { 2'b11, 4'bzz01, {OPX} };
endpackage
module dut (input logic [7:0] insn, output int o, output int p);
  import tp::W_A;
  import tp::W_B;
  task automatic t(input logic [7:0] i, output int r);
    casez (i)
      W_A: r = 1;
      default: r = 0;
    endcase
  endtask
  always_comb begin
    case (insn)
      W_B: o = 5;
      default: o = 0;
    endcase
  end
  always_comb t(insn, p);
endmodule
