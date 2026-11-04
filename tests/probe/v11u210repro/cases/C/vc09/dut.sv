// § caseItemImpWildParamScopeName210 — vc09 (v11u210 break probe): a PLAIN wildcard literal parameter (no concatenation): golden substitutes the constant in the case item, ours keeps a reference the law renames
package tp;
  parameter logic [3:0] W2 = 4'b??11;
  parameter logic [3:0] N1 = 4'b0011;
endpackage
module dut import tp::*; (input logic [3:0] a, output logic [1:0] o);
  always_comb begin
    casez (a)
      W2: o = 2'd1;
      N1: o = 2'd2;
      default: o = 2'd0;
    endcase
  end
endmodule
