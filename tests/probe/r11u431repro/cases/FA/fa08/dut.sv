// § caFnArgConcatFormalTs431
module top(input [5:0] a, input [4:0] c, output [3:0] y);
function [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({a[1], c});
endmodule
