// § caFnArgConcatFormalTs431 (a nested concatenation)
module top(input [5:0] a, output [3:0] y);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({{a[1:0], a[3:2]}, a[5:4]});
endmodule
