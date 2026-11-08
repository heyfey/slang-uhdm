// § enumCastChainKeepsInnerCast493
module m #(parameter int W = 4)(input logic [W-1:0] a, output logic [W-1:0] y);
  function automatic logic [W-1:0] g(logic [W-1:0] s);
    return s + 1'b1;
  endfunction
  assign y = W'(W'(g(a)));
endmodule
module top(input logic [3:0] a4, input logic [7:0] a8, output logic [3:0] y4, output logic [7:0] y8);
  m #(4) u4(a4, y4);
  m #(8) u8(a8, y8);
endmodule
