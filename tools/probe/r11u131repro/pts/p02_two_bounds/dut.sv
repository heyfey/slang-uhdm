// § pkgParamTsRefColons131
package pk;
  parameter int N = 4;
  parameter int M = 1;
  parameter logic [N-1:M] A = '1;
endpackage
module top(output logic o); assign o = pk::A[1]; endmodule
