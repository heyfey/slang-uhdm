// § caLhsDefNetUnlessOpRhs139
module top(input p, output a);
  function automatic logic f(input logic x); return ~x; endfunction
  assign a = f(p);
endmodule
