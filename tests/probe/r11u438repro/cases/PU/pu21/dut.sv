// § caPlainLhsUnsizedClone438 (control: a user call abstains, the reduce leg)
package pk;
  function automatic logic f(input logic a); return ~a; endfunction
endpackage
module sub(input [15:0] b, output y);
  assign y = pk::f(b['h1]);
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
