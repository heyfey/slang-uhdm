// § caPlainLhsUnsizedClone438 (control: a user call abstains, the reduce leg)
module sub(input [15:0] b, output y);
  function automatic logic f(input logic a); return ~a; endfunction
  assign y = f(b['h1]);
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
