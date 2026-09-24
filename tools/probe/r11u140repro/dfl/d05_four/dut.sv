// § defaultFillOneConstant140
module top #(parameter logic [3:0] A[4] = '{default: 4'h9}) (output logic [3:0] o);
  assign o = A[2];
endmodule
