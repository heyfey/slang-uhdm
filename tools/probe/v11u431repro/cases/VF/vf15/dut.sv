// § caFnArgConcatFormalTs431 (whole right side with a concatenated left side)
module top(input [5:0] a, output [1:0] y1, output [1:0] y2);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign {y1, y2} = f({a[2:0], a[5:3]});
endmodule
