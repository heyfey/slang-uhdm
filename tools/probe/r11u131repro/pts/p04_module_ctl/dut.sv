// § pkgParamTsRefColons131
module top #(parameter int N = 4, parameter logic [N-1:0] A = '1) (output logic o);
  assign o = A[0];
endmodule
