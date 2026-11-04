// § caFnArgConcatFormalTs431
module top(input [5:0] a, output [3:0] y);
function [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({2{a[2:0]}});
endmodule
