// § caFnArgConcatFormalTs431 (a $unit function)
function automatic logic [3:0] uf(input logic [5:0] b);
  return b[3:0];
endfunction
module top(input [5:0] a, output [3:0] y);
assign y = uf({a[2:0], a[5:3]});
endmodule
