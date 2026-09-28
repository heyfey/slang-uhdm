// § caseItemImpWildParamScopeName210 — vc04 (v11u210 break probe): a static function of a CLASS IN ANOTHER PACKAGE reads the wildcard-valued imported parameter in a casez item
package tp;
  parameter logic [7:0] I_WILD = { 2'b01, 2'b??, 4'b1100 };
endpackage
package cp;
  import tp::*;
  class K;
    static function int f(logic [7:0] i);
      casez (i)
        I_WILD: return 1;
        default: return 0;
      endcase
    endfunction
  endclass
endpackage
module dut(input logic [7:0] insn, output int o);
  assign o = cp::K::f(insn);
endmodule
