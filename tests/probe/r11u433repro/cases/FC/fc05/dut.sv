// § caFnArgConcatFormalTs431 (a concatenation of parameters only)
module top(output [3:0] y);
localparam [3:0] P = 4'h1, Q = 4'h2;
function automatic [3:0] f(input [7:0] b);
  f = b[3:0];
endfunction
assign y = f({P, Q});
endmodule
