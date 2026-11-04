// § replCountFoldFile140
module test #(parameter int N = 2, parameter int unsigned A[N] = '{N{'1}}) (output int unsigned o);
  assign o = A[0];
endmodule
