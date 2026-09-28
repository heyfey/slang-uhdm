// § caseItemImpWildParamScopeName210 — vc02 (v11u210 break probe): an INTERFACE body importing the package and reading the wildcard-valued parameter in a casez item, instantiated in a module
package tp;
  parameter logic [7:0] I_WILD = { 2'b01, 2'b??, 4'b1100 };
endpackage
interface itf(input logic [7:0] a);
  import tp::*;
  int r;
  always_comb begin
    casez (a)
      I_WILD: r = 1;
      default: r = 0;
    endcase
  end
endinterface
module dut(input logic [7:0] insn, output int q);
  itf u(.a(insn));
  assign q = u.r;
endmodule
