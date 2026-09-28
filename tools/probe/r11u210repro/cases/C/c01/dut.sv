// § caseItemImpWildParamScopeName210 — c01: casez items reading wildcard-imported package parameters with and without ? digits, in an always_comb and in a function (ibex_tracer's decoder)
package tp;
  parameter logic [1:0] OP_A = 2'b10;
  parameter logic [7:0] I_PLAIN = { 6'b000001, {OP_A} };
  parameter logic [7:0] I_WILD  = { 3'b010, 3'h?, {OP_A} };
endpackage
module dut import tp::*; (input logic [7:0] insn, output int o, output int p);
  function automatic int dec(logic [7:0] i);
    unique casez (i)
      I_WILD:  return 3;
      I_PLAIN: return 4;
      default: return 0;
    endcase
  endfunction
  always_comb begin
    o = 0;
    unique casez (insn)
      I_PLAIN: o = 1;
      I_WILD:  o = 2;
      default: o = 0;
    endcase
  end
  assign p = dec(insn);
endmodule
