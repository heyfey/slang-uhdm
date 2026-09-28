// § caseItemImpWildParamScopeName210 — vc03 (v11u210 break probe): a CLASS method declared in the module reads the wildcard-valued imported parameter in a casez item
package tp;
  parameter logic [7:0] I_WILD = { 2'b01, 2'b??, 4'b1100 };
endpackage
module dut(input logic [7:0] insn, output int p);
  import tp::*;
  class L;
    function int g(logic [7:0] i);
      casez (i)
        I_WILD: return 2;
        default: return 0;
      endcase
    endfunction
  endclass
  always_comb begin
    L h;
    h = new;
    p = h.g(insn);
  end
endmodule
