// § pkgParamTsRefColons131
package pk;
  parameter int N = 4;
  parameter logic [N-1:0] A = '1;
endpackage
module top import pk::*; (output logic o); assign o = A[0]; endmodule
