// § defaultFillOneConstant140
module top #(parameter int N = 2, parameter int unsigned A[N] = '{default: '1}) (output int unsigned o);
  assign o = A[0];
endmodule
