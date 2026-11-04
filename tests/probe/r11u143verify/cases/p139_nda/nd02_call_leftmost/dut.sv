// § ndaLeftmostLeafElab139
// case nd02: a net declaration assignment whose left operand is a function call
module top(input logic [3:0] a, input logic [3:0] b, output logic [3:0] y);
  function automatic logic [3:0] inv(input logic [3:0] v); return ~v; endfunction
  wire [3:0] w = inv(a) & b;
  assign y = w;
endmodule
