// § caFnArgConcatFormalTs431 (a net declaration assignment)
module top(input [5:0] a, output [3:0] y);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
wire [3:0] w = f({a[2:0], a[5:3]});
assign y = w;
endmodule
