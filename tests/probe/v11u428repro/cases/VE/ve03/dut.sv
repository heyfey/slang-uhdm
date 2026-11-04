// § synCaseEqXnorOps428
module m #(parameter W = 4) (input [W-1:0] a, output [W-1:0] o);
  for (genvar i = 0; i < W; i++) begin: g
    assign o[i] = (a[i] === 1'bz);
  end
endmodule
module top(input [3:0] a, output [3:0] o);
  m #(4) u(a, o);
endmodule
