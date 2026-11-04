// § caFnArgConcatFormalTs431
module sub(input [11:0] a, output [3:0] y);
function [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({a[8:6], a[11:9]});
endmodule
module top(input [11:0] a, output [3:0] y);
sub u(.a(a), .y(y));
endmodule
