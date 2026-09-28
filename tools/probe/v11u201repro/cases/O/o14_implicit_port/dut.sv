// § opCtxRefArgBare201
module top(input logic [3:0] a, output o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  wire [3:0] w;
  assign w = f(a) * 4'd3;
  assign o = f(a) > 4'd3;
endmodule
