// § oneTickUpperBNormalized425
module top(input logic [1:0] s, output logic o);
  always_comb case (s[0])
    1'B0: o = 1'B1;
    1'B1: o = 1'B0;
    default: o = 1'Bx;
  endcase
endmodule
