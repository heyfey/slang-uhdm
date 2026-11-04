// § ndaUnsizedRhsFreshLhs438 (control: a user call abstains)
module sub(input [15:0] b, output y);
  function automatic logic f(input logic a); return ~a; endfunction
  wire w = f(b['h1]);
  assign y = w;
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
