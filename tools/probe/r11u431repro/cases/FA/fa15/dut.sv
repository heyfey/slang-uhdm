// § caFnArgConcatFormalTs431
module top(input [2:0] a, input [2:0] c, output [3:0] y);
function automatic [3:0] f(input logic [5:0] b, input int k);
  f = b[3:0] + k;
endfunction
assign y = f({a, c}, 2);
endmodule
