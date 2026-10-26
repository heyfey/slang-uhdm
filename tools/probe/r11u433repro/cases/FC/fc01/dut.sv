// § caFnArgConcatFormalTs431 (control: a concatenation of literals)
module top(output [3:0] y);
function automatic [3:0] f(input [7:0] b);
  f = b[3:0];
endfunction
assign y = f({4'h1, 4'h2});
endmodule
