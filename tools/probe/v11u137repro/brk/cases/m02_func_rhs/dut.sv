// § caLhsDefNetUnlessOpRhs139
module sub(input logic [3:0] a, output logic [3:0] y, output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] v); return ~v; endfunction
  assign y = f(a);
  assign z = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] a, b);
  sub u(.a(x), .y(a), .z(b));
endmodule
