// § caFnArgConcatFormalTs431 (a second argument, the first a plain signal)
module top(input [5:0] a, input [1:0] c, output [3:0] y);
function automatic [3:0] f(input [1:0] s, input [5:0] b);
  f = b[3:0] ^ s;
endfunction
assign y = f(c, {a[2:0], c, a[5]});
endmodule
