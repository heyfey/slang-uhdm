// § sysArgUnaryConstSelToken140v
module top(input logic [31:0] x, input logic [7:0] a, output logic [7:0] o);
  localparam int T[10] = '{0,1,2,3,4,5,6,7,8,9};
  assign o = x[T[$bits(~a)]-1:0];
endmodule
