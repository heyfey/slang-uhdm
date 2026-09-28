// § caseItemImpWildParamScopeName210 — vc01 (v11u210 break probe): the casez sits in a FUNCTION OF ANOTHER PACKAGE that wildcard-imports the wildcard-valued parameter, called from a module
package tp;
  parameter logic [7:0] I_WILD = { 3'b010, 3'h?, 2'b10 };
  parameter logic [7:0] I_PLAIN = 8'b0000_0110;
endpackage
package dp;
  import tp::*;
  function automatic int dec(logic [7:0] i);
    casez (i)
      I_WILD:  return 3;
      I_PLAIN: return 4;
      default: return 0;
    endcase
  endfunction
endpackage
module dut(input logic [7:0] insn, output int o);
  assign o = dp::dec(insn);
endmodule
