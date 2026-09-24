// § pkgParamTsRefColons131
package pk;
  parameter int N = 4;
  parameter logic [N-1:0] A = '1;
endpackage
module top(output logic o); assign o = 1'b0; endmodule
