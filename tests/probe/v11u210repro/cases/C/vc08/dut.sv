// § caseItemImpWildParamScopeName210 — vc08 (v11u210 control): case ... inside reading the wildcard-valued imported parameter (the other arm of the case-item loop, not reached by the law)
package tp;
  parameter logic [3:0] W2 = { 2'b??, 2'b11 };
endpackage
module dut import tp::*; (input logic [3:0] a, output int o);
  always_comb begin
    case (a) inside
      W2: o = 1;
      default: o = 0;
    endcase
  end
endmodule
