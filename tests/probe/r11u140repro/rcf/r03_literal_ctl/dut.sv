// § replCountFoldFile140
module test #(parameter logic [3:0] A[2] = '{2{4'h5}}) (output logic [3:0] o);
  assign o = A[1];
endmodule
