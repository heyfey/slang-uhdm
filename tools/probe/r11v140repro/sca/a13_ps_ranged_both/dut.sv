// § sysArgUnaryWholeSpan140
module top(input logic [31:0] x, input logic [7:0] a, output logic [7:0] o);
  assign o = x[$bits(~a)-1:$bits(-a)-8];
endmodule
