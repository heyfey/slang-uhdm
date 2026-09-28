// § caseItemImpWildParamScopeName210 — r11u217 c02: plain wildcard literals WITHOUT a concatenation (`4'b??11`, `4'bx0z1`, `4'b1z?0`) read as casez / casex items (v11u210 F1: golden substitutes a constant)
package tp;
  parameter logic [3:0] W1 = 4'b??11;
  parameter logic [3:0] W2 = 4'bx0z1;
  parameter logic [3:0] W3 = 4'b1z?0;
endpackage
module dut import tp::*; (input logic [3:0] a, output int o);
  always_comb begin
    o = 0;
    casez (a)
      W1: o = 1;
      W3: o = 3;
      default: o = 0;
    endcase
    casex (a)
      W2: o = 2;
      default: ;
    endcase
  end
endmodule
