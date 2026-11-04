// § defaultFillOneConstant140
module top #(parameter int A[1] = '{default: 7}) (output int o);
  assign o = A[0];
endmodule
