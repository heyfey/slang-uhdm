// § opCtxRefArgBare201
module top(a, o1, o2);
  input [3:0] a;
  output [3:0] o1;
  output o2;
  function automatic [3:0] f(input [3:0] v); f = v + 1; endfunction
  assign o1 = f(a) | 4'd1;
  assign o2 = f(a) != 4'd3;
endmodule
