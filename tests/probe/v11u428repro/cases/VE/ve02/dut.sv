// § synCaseEqXnorOps428
module top(input [3:0] a, b, output [3:0] o);
  for (genvar i = 0; i < 4; i++) begin: g
    assign o[i] = (a[i] ^~ b[i]) | (a !== b);
  end
endmodule
