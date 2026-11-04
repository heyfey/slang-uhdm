// § caFnArgConcatFormalTs431
module top(input [2:0] a, input [2:0] c, output [3:0] y);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({a, c});
endmodule
