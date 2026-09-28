// § pkgEnumAliasListingParent212 § caseItemImpWildParamScopeName210 — r11u217 x04: a casez whose items read a wildcard-concatenation parameter AND an enum-alias constant, both imported from one package that declares the alias
package tp;
  typedef enum logic [7:0] { K0 = 8'h00, K1 = 8'h81 } e_t;
  typedef e_t f_t;
  parameter logic [1:0] OP = 2'b01;
  parameter logic [7:0] I_Q = { 3'b110, 3'h?, {OP} };
  parameter f_t FA = K1;
endpackage
module dut import tp::*; (input logic [7:0] insn, output int o);
  always_comb begin
    o = 0;
    casez (insn)
      I_Q: o = 1;
      FA: o = 2;
      default: o = 0;
    endcase
  end
endmodule
