// § caPlainLhsUnsizedClone438 (control: a user call abstains, the reduce leg)
module sub(input [15:0] b, output [15:0] y);
  function automatic logic [15:0] f(input logic [15:0] a, input int k); return a >> k; endfunction
  assign y = f(b, 'h3);
endmodule
module top(input [15:0] b, output [15:0] y);
  sub u(.b(b), .y(y));
endmodule
