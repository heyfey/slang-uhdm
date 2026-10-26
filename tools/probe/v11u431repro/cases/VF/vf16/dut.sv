// § caFnConcatWholeRhsOnly431v (under a unary operator and under a select)
module top(input [5:0] a, output [3:0] y, output z);
function automatic [3:0] f(input [5:0] b);
  f = b[3:0];
endfunction
assign y = ~f({a[2:0], a[5:3]});
assign z = f({a[1:0], a[5:2]}) == 4'd3;
endmodule
