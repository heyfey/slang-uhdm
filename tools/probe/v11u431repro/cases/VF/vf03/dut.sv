// § caFnConcatWholeRhsOnly431v (a call under an operation)
module top(input [5:0] a, output [3:0] y);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = f({a[2:0], a[5:3]}) + 4'd1;
endmodule
