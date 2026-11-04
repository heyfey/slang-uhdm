// § pkgParamTsRefColons131
package a;
  parameter int N = 4;
endpackage
package b;
  localparam int N = a::N;
  localparam bit [N-1:0] B = '0;
endpackage
module top(output logic o); assign o = b::B[0]; endmodule
