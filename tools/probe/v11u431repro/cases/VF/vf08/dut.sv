// § caFnArgConcatFormalTs431 (a concatenation argument of a call inside a call argument)
module top(input [5:0] a, output [3:0] y);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
function automatic [3:0] g(input [3:0] b);
  g = ~b;
endfunction
assign y = g(f({a[2:0], a[5:3]}));
endmodule
