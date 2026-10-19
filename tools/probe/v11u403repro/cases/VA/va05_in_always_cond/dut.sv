// § operatorAttrsListed403
module top(input s, input [3:0] a, b, output logic [3:0] y);
  always_comb y = s ? (* full *) a : b;
endmodule
