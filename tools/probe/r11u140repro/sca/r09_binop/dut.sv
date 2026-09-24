// § sysArgUnaryWholeSpan140
module top(input logic [7:0] a, input logic [7:0] b, output logic [31:0] out, output logic [31:0] o2);
  assign out = $bits(~a) - 1;
endmodule
