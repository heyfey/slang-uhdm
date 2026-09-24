// § replCountFoldFile140
module test #(parameter int N = 3, parameter logic [3:0] A[N] = '{N{4'h5}}) (output logic [3:0] o);
  assign o = A[1];
endmodule
