// § caseItemWildConcatOnly215 — a plain wildcard literal parameter and a concatenation-bearing one in one casez (the r11u210 verifier's F1: only the latter keeps the scope-named reference)
package tp;
  parameter logic [3:0] W2 = 4'b??11;
  parameter logic [7:0] WC = {4'b01??, 4'h3};
  parameter logic [3:0] N1 = 4'b0011;
endpackage
module dut import tp::*; (input logic [3:0] a, input logic [7:0] b, output logic [1:0] o, output logic p);
  always_comb begin
    casez (a)
      W2: o = 2'd1;
      N1: o = 2'd2;
      default: o = 2'd0;
    endcase
    casez (b)
      WC: p = 1'b1;
      default: p = 1'b0;
    endcase
  end
endmodule
