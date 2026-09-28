// § caseItemImpWildParamScopeName210 — vc10 (v11u210 break probe): the package is imported in the COMPILATION-UNIT scope ($unit, outside any module), the casez in an always_comb
package tp;
  parameter logic [3:0] W2 = { 2'b??, 2'b11 };
endpackage
import tp::*;
module dut(input logic [3:0] a, output logic [1:0] o);
  always_comb begin
    casez (a)
      W2: o = 2'd1;
      default: o = 2'd0;
    endcase
  end
endmodule
