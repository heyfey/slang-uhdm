// § boundSizedLitKept424
module top;
  function logic [4'h7:0] f(input logic [4'd3:0] a); return {4'h0, a}; endfunction
  logic [7:0] r;
  initial r = f(4'h2);
endmodule
