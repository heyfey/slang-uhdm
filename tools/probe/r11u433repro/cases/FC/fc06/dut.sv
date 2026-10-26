// § caFnArgConcatFormalTs431 (a parameter and a literal)
module top(output [3:0] y);
localparam [3:0] P = 4'h1;
function automatic [3:0] f(input [7:0] b);
  f = b[3:0];
endfunction
assign y = f({P, 4'h2});
endmodule
