// § sysArgUnaryConstSelToken140v
module top(input logic [31:0] x, input logic [7:0] a, output logic o);
  assign o = x[$bits(a[$bits(~a)-1:0])];
endmodule
