// § caseItemWildConcatOnly217v — r11u217 c04: in one casez, a PLAIN wildcard parameter (`8'b1??0_0011`), a concatenation-bearing wildcard parameter (`{3'b1?0, 5'h3}`) and a concatenation-bearing one with a nested parameter (`{2'b1?, {OP}, 4'h0}`), all wildcard-imported
package tp;
  parameter logic [1:0] OP = 2'b01;
  parameter logic [7:0] W_PLAIN = 8'b1??0_0011;
  parameter logic [7:0] W_CAT   = { 3'b1?0, 5'h3 };
  parameter logic [7:0] W_NEST  = { 2'b1?, {OP}, 4'h0 };
endpackage
module dut import tp::*; (input logic [7:0] a, output int o);
  always_comb begin
    o = 0;
    casez (a)
      W_PLAIN: o = 1;
      W_CAT:   o = 2;
      W_NEST:  o = 3;
      default: o = 0;
    endcase
  end
endmodule
