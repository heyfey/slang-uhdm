// § caFnArgConcatFormalTs431 (control: a concatenation of whole names, no stamp in the definition)
module top(input [2:0] a, input [2:0] c, output [3:0] y);
function [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({a, c});
endmodule
