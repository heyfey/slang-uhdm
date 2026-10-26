// § caFnArgConcatFormalTs431
module top(input [3:0] a, input [3:0] c, output [3:0] y);
typedef logic [7:0] word;
function automatic [3:0] f(input word b);
  f = b[3:0];
endfunction
assign y = f({a, c});
endmodule
