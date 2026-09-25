// § ppOutputCol166
`define F f
module top(input a, output o);
  function automatic logic f(input logic x); return ~x; endfunction
  assign o = `F (a);
endmodule
